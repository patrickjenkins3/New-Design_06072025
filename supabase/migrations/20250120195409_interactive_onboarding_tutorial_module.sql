-- Location: supabase/migrations/20250120195409_interactive_onboarding_tutorial_module.sql
-- Schema Analysis: Existing schema has user_profiles table and user_role enum
-- Integration Type: NEW_MODULE - Adding interactive tutorial tracking functionality
-- Dependencies: References existing user_profiles table

-- 1. Create Tutorial-related Types
CREATE TYPE public.tutorial_stage AS ENUM (
    'dashboard_overview',
    'school_search', 
    'scholarship_matching',
    'calendar_integration',
    'family_collaboration'
);

CREATE TYPE public.tutorial_status AS ENUM (
    'not_started',
    'in_progress', 
    'completed',
    'skipped'
);

CREATE TYPE public.user_type AS ENUM (
    'parent',
    'teen'
);

-- 2. Create Onboarding Tutorial Progress Table
CREATE TABLE public.onboarding_tutorial_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    tutorial_stage public.tutorial_stage NOT NULL,
    status public.tutorial_status DEFAULT 'not_started'::public.tutorial_status,
    completed_at TIMESTAMPTZ,
    skipped_at TIMESTAMPTZ,
    stage_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, tutorial_stage)
);

-- 3. Create User Personalization Table
CREATE TABLE public.user_personalization (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    user_type public.user_type,
    graduation_year INTEGER,
    college_interests TEXT[],
    location_preferences TEXT[],
    interests_data JSONB DEFAULT '{}'::jsonb,
    onboarding_completed BOOLEAN DEFAULT false,
    trial_extended BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create Tutorial Achievements/Badges Table
CREATE TABLE public.tutorial_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL,
    achievement_name TEXT NOT NULL,
    description TEXT,
    earned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    badge_data JSONB DEFAULT '{}'::jsonb,
    
    UNIQUE(user_id, achievement_type)
);

-- 5. Create Essential Indexes
CREATE INDEX idx_onboarding_tutorial_progress_user_id ON public.onboarding_tutorial_progress(user_id);
CREATE INDEX idx_onboarding_tutorial_progress_stage ON public.onboarding_tutorial_progress(tutorial_stage);
CREATE INDEX idx_onboarding_tutorial_progress_status ON public.onboarding_tutorial_progress(status);
CREATE INDEX idx_user_personalization_user_id ON public.user_personalization(user_id);
CREATE INDEX idx_tutorial_achievements_user_id ON public.tutorial_achievements(user_id);

-- 6. RLS Setup
ALTER TABLE public.onboarding_tutorial_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_personalization ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorial_achievements ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies (Following Pattern 2 - Simple User Ownership)
CREATE POLICY "users_manage_own_onboarding_tutorial_progress"
ON public.onboarding_tutorial_progress
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_personalization"
ON public.user_personalization
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_tutorial_achievements"
ON public.tutorial_achievements
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. Functions for Tutorial Management
CREATE OR REPLACE FUNCTION public.initialize_user_tutorial(user_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Initialize all tutorial stages for the user
    INSERT INTO public.onboarding_tutorial_progress (user_id, tutorial_stage, status)
    VALUES 
        (user_uuid, 'dashboard_overview', 'not_started'),
        (user_uuid, 'school_search', 'not_started'),
        (user_uuid, 'scholarship_matching', 'not_started'),
        (user_uuid, 'calendar_integration', 'not_started'),
        (user_uuid, 'family_collaboration', 'not_started')
    ON CONFLICT (user_id, tutorial_stage) DO NOTHING;
    
    -- Initialize personalization record
    INSERT INTO public.user_personalization (user_id)
    VALUES (user_uuid)
    ON CONFLICT (user_id) DO NOTHING;
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_tutorial_stage(
    user_uuid UUID,
    stage_name public.tutorial_stage,
    stage_data_json JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.onboarding_tutorial_progress
    SET 
        status = 'completed',
        completed_at = CURRENT_TIMESTAMP,
        stage_data = stage_data_json,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = user_uuid AND tutorial_stage = stage_name;
    
    -- Check if all stages are completed and award completion badge
    IF (SELECT COUNT(*) FROM public.onboarding_tutorial_progress 
        WHERE user_id = user_uuid AND status = 'completed') = 5 THEN
        
        INSERT INTO public.tutorial_achievements (user_id, achievement_type, achievement_name, description)
        VALUES (user_uuid, 'tutorial_completion', 'Onboarding Master', 'Completed the full interactive onboarding tutorial')
        ON CONFLICT (user_id, achievement_type) DO NOTHING;
        
        -- Mark onboarding as completed and extend trial
        UPDATE public.user_personalization
        SET onboarding_completed = true, trial_extended = true
        WHERE user_id = user_uuid;
    END IF;
END;
$$;

-- 9. Trigger for Updated At
CREATE OR REPLACE FUNCTION public.update_updated_at_onboarding()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_onboarding_tutorial_progress_updated_at
    BEFORE UPDATE ON public.onboarding_tutorial_progress
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_onboarding();

CREATE TRIGGER update_user_personalization_updated_at
    BEFORE UPDATE ON public.user_personalization
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_onboarding();

-- 10. Mock Data for Tutorial System
DO $$
DECLARE
    existing_user_id UUID;
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Initialize tutorial for existing user
        PERFORM public.initialize_user_tutorial(existing_user_id);
        
        -- Set some personalization data
        UPDATE public.user_personalization
        SET 
            user_type = 'teen',
            graduation_year = 2025,
            college_interests = ARRAY['Computer Science', 'Engineering', 'Business'],
            location_preferences = ARRAY['California', 'New York', 'Texas']
        WHERE user_id = existing_user_id;
        
        -- Complete first stage as sample
        PERFORM public.complete_tutorial_stage(
            existing_user_id, 
            'dashboard_overview',
            '{"interactions": 3, "time_spent": 120}'::jsonb
        );
    END IF;
END $$;