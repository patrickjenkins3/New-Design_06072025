-- Location: supabase/migrations/20250925135137_tasks_module.sql
-- Schema Analysis: Existing scholarship/education app with user_profiles, scholarships, subscriptions
-- Integration Type: NEW_MODULE (adding task management functionality)
-- Dependencies: user_profiles (existing table for user relationships)

-- IMPLEMENTING MODULE: Task Management
-- Module scope: Creating task management system for users to track their activities

-- 1. Create task status enum type
CREATE TYPE public.task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- 2. Create task priority enum type  
CREATE TYPE public.task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- 3. Create tasks table that references existing user_profiles
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status public.task_status DEFAULT 'pending'::public.task_status NOT NULL,
    priority public.task_priority DEFAULT 'medium'::public.task_priority NOT NULL,
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 4. Create indexes for efficient querying
CREATE INDEX idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_priority ON public.tasks(priority);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX idx_tasks_created_at ON public.tasks(created_at);

-- 5. Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_tasks_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 6. Create trigger to automatically update updated_at
CREATE TRIGGER update_tasks_updated_at_trigger
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW
    EXECUTE FUNCTION public.update_tasks_updated_at();

-- 7. Enable RLS on tasks table
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- 8. Create RLS policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_tasks"
ON public.tasks
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 9. Mock data for existing users (referencing existing user_profiles)
DO $$
DECLARE
    existing_user_id_1 UUID;
    existing_user_id_2 UUID;
    task1_id UUID := gen_random_uuid();
    task2_id UUID := gen_random_uuid();
    task3_id UUID := gen_random_uuid();
    task4_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs from user_profiles (don't create new ones)
    SELECT id INTO existing_user_id_1 FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_user_id_2 FROM public.user_profiles LIMIT 1 OFFSET 1;

    -- Only insert mock tasks if users exist
    IF existing_user_id_1 IS NOT NULL THEN
        INSERT INTO public.tasks (id, user_id, title, description, status, priority, due_date) VALUES
            (task1_id, existing_user_id_1, 'Complete College Application', 'Finish application for Stanford University including essays and recommendations', 'in_progress'::public.task_status, 'high'::public.task_priority, CURRENT_TIMESTAMP + INTERVAL '7 days'),
            (task2_id, existing_user_id_1, 'Research Scholarships', 'Find and apply to merit-based scholarships for computer science majors', 'pending'::public.task_status, 'medium'::public.task_priority, CURRENT_TIMESTAMP + INTERVAL '14 days');
    END IF;

    IF existing_user_id_2 IS NOT NULL THEN
        INSERT INTO public.tasks (id, user_id, title, description, status, priority, due_date, completed_at) VALUES
            (task3_id, existing_user_id_2, 'Submit FAFSA Form', 'Complete and submit Free Application for Federal Student Aid', 'completed'::public.task_status, 'urgent'::public.task_priority, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
            (task4_id, existing_user_id_2, 'Schedule Campus Visit', 'Arrange campus tour for preferred universities', 'pending'::public.task_status, 'low'::public.task_priority, CURRENT_TIMESTAMP + INTERVAL '21 days');
    END IF;

    -- Log if no existing users found
    IF existing_user_id_1 IS NULL THEN
        RAISE NOTICE 'No existing users found. Run authentication setup first to create users.';
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: Please ensure user_profiles table exists and has data';
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error in mock data creation: %', SQLERRM;
END $$;