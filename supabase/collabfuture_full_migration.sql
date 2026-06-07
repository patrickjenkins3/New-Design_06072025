-- ============================================================
-- CollabFuture — Full Database Migration
-- New Design_06072025
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Safe to re-run: uses IF NOT EXISTS / DO $$ guards throughout
-- Order: tasks → calendar → subscriptions → onboarding → security → scholarships
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- MIGRATION 1 of 6: Subscription System
-- ────────────────────────────────────────────────────────────

-- Types (safe to create only if missing)
DO $$ BEGIN
  CREATE TYPE public.subscription_status AS ENUM ('active', 'canceled', 'past_due', 'unpaid', 'trialing');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.billing_interval AS ENUM ('monthly', 'yearly');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.user_role AS ENUM ('free', 'premium', 'admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- User profiles
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'free'::public.user_role,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Subscription plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    billing_interval public.billing_interval NOT NULL,
    stripe_price_id TEXT UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.subscription_plans(id) ON DELETE CASCADE,
    stripe_subscription_id TEXT UNIQUE,
    stripe_customer_id TEXT,
    status public.subscription_status DEFAULT 'trialing'::public.subscription_status,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Payment history
CREATE TABLE IF NOT EXISTS public.payment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE CASCADE,
    stripe_payment_intent_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'usd',
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_subscription_id ON public.subscriptions(stripe_subscription_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_user_id ON public.payment_history(user_id);

-- Functions
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER SECURITY DEFINER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'free')::public.user_role
  ) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_subscription_role()
RETURNS TRIGGER SECURITY DEFINER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'active' THEN
    UPDATE public.user_profiles SET role = 'premium'::public.user_role, updated_at = CURRENT_TIMESTAMP WHERE id = NEW.user_id;
  ELSIF NEW.status IN ('canceled', 'past_due', 'unpaid') THEN
    UPDATE public.user_profiles SET role = 'free'::public.user_role, updated_at = CURRENT_TIMESTAMP WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$;

-- RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_history ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_user_profiles" ON public.user_profiles FOR ALL TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "public_can_read_subscription_plans" ON public.subscription_plans FOR SELECT TO public USING (is_active = true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "admins_manage_subscription_plans" ON public.subscription_plans FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM auth.users au WHERE au.id = auth.uid() AND au.raw_user_meta_data->>'role' = 'admin'))
    WITH CHECK (EXISTS (SELECT 1 FROM auth.users au WHERE au.id = auth.uid() AND au.raw_user_meta_data->>'role' = 'admin'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_subscriptions" ON public.subscriptions FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "users_view_own_payment_history" ON public.payment_history FOR SELECT TO authenticated USING (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS on_subscription_status_changed ON public.subscriptions;
CREATE TRIGGER on_subscription_status_changed
  AFTER UPDATE ON public.subscriptions FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.update_subscription_role();

-- Seed subscription plans
INSERT INTO public.subscription_plans (name, description, price, billing_interval, stripe_price_id, is_active)
VALUES
  ('Free Plan',    'Basic features for exploring CollabFuture',                              0.00,  'monthly', null,                  true),
  ('Premium Plan', 'Full access with AI tools, advanced search, and priority support',       9.99,  'monthly', 'price_premium_monthly', true),
  ('Family Plan',  'Premium for the whole family — students, parents, and counselors',       14.99, 'monthly', 'price_family_monthly',  true),
  ('Annual Plan',  'Full access billed annually — save 40%',                                 59.99, 'yearly',  'price_annual_yearly',   true)
ON CONFLICT (stripe_price_id) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- MIGRATION 2 of 6: Tasks Module
-- ────────────────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE public.task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.task_priority AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.tasks (
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

CREATE INDEX IF NOT EXISTS idx_tasks_user_id   ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status     ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority   ON public.tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date   ON public.tasks(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON public.tasks(created_at);

CREATE OR REPLACE FUNCTION public.update_tasks_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS update_tasks_updated_at_trigger ON public.tasks;
CREATE TRIGGER update_tasks_updated_at_trigger
  BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.update_tasks_updated_at();

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_tasks" ON public.tasks FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- ────────────────────────────────────────────────────────────
-- MIGRATION 3 of 6: Calendar Events Enhancement
-- ────────────────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE public.event_type AS ENUM ('application', 'scholarship', 'test', 'visit', 'deadline', 'meeting');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.assignment_target AS ENUM ('teen', 'parent', 'both', 'family');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS event_type public.event_type DEFAULT 'deadline'::public.event_type;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS school_name TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS assigned_to public.assignment_target DEFAULT 'teen'::public.assignment_target;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS is_all_day BOOLEAN DEFAULT false;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS start_time TIME;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS end_time TIME;

CREATE INDEX IF NOT EXISTS idx_tasks_event_type   ON public.tasks(event_type);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to  ON public.tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_school_name  ON public.tasks(school_name) WHERE school_name IS NOT NULL;


-- ────────────────────────────────────────────────────────────
-- MIGRATION 4 of 6: Interactive Onboarding Tutorial
-- ────────────────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE public.tutorial_stage AS ENUM ('dashboard_overview','school_search','scholarship_matching','calendar_integration','family_collaboration');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.tutorial_status AS ENUM ('not_started','in_progress','completed','skipped');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.user_type AS ENUM ('parent','teen');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.onboarding_tutorial_progress (
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

CREATE TABLE IF NOT EXISTS public.user_personalization (
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

CREATE TABLE IF NOT EXISTS public.tutorial_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL,
    achievement_name TEXT NOT NULL,
    description TEXT,
    earned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    badge_data JSONB DEFAULT '{}'::jsonb,
    UNIQUE(user_id, achievement_type)
);

CREATE INDEX IF NOT EXISTS idx_onboarding_tutorial_progress_user_id ON public.onboarding_tutorial_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_tutorial_progress_stage   ON public.onboarding_tutorial_progress(tutorial_stage);
CREATE INDEX IF NOT EXISTS idx_onboarding_tutorial_progress_status  ON public.onboarding_tutorial_progress(status);
CREATE INDEX IF NOT EXISTS idx_user_personalization_user_id          ON public.user_personalization(user_id);
CREATE INDEX IF NOT EXISTS idx_tutorial_achievements_user_id         ON public.tutorial_achievements(user_id);

ALTER TABLE public.onboarding_tutorial_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_personalization          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorial_achievements         ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_onboarding_tutorial_progress" ON public.onboarding_tutorial_progress FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_user_personalization" ON public.user_personalization FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "users_manage_own_tutorial_achievements" ON public.tutorial_achievements FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION public.initialize_user_tutorial(user_uuid UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.onboarding_tutorial_progress (user_id, tutorial_stage, status) VALUES
    (user_uuid, 'dashboard_overview',   'not_started'),
    (user_uuid, 'school_search',        'not_started'),
    (user_uuid, 'scholarship_matching', 'not_started'),
    (user_uuid, 'calendar_integration', 'not_started'),
    (user_uuid, 'family_collaboration', 'not_started')
  ON CONFLICT (user_id, tutorial_stage) DO NOTHING;
  INSERT INTO public.user_personalization (user_id) VALUES (user_uuid) ON CONFLICT (user_id) DO NOTHING;
END; $$;

CREATE OR REPLACE FUNCTION public.complete_tutorial_stage(
    user_uuid UUID, stage_name public.tutorial_stage, stage_data_json JSONB DEFAULT '{}'::jsonb)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.onboarding_tutorial_progress
  SET status = 'completed', completed_at = CURRENT_TIMESTAMP, stage_data = stage_data_json, updated_at = CURRENT_TIMESTAMP
  WHERE user_id = user_uuid AND tutorial_stage = stage_name;
  IF (SELECT COUNT(*) FROM public.onboarding_tutorial_progress WHERE user_id = user_uuid AND status = 'completed') = 5 THEN
    INSERT INTO public.tutorial_achievements (user_id, achievement_type, achievement_name, description)
    VALUES (user_uuid, 'tutorial_completion', 'Onboarding Master', 'Completed the full interactive onboarding tutorial')
    ON CONFLICT (user_id, achievement_type) DO NOTHING;
    UPDATE public.user_personalization SET onboarding_completed = true, trial_extended = true WHERE user_id = user_uuid;
  END IF;
END; $$;

CREATE OR REPLACE FUNCTION public.update_updated_at_onboarding()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS update_onboarding_tutorial_progress_updated_at ON public.onboarding_tutorial_progress;
CREATE TRIGGER update_onboarding_tutorial_progress_updated_at
  BEFORE UPDATE ON public.onboarding_tutorial_progress FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_onboarding();

DROP TRIGGER IF EXISTS update_user_personalization_updated_at ON public.user_personalization;
CREATE TRIGGER update_user_personalization_updated_at
  BEFORE UPDATE ON public.user_personalization FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_onboarding();


-- ────────────────────────────────────────────────────────────
-- MIGRATION 5 of 6: Security Features
-- ────────────────────────────────────────────────────────────

DO $$ BEGIN CREATE TYPE public.session_status AS ENUM ('active', 'expired', 'revoked', 'suspicious'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.auth_method   AS ENUM ('password', 'biometric', 'pin', 'pattern');      EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.device_type   AS ENUM ('mobile', 'tablet', 'desktop', 'web');            EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.security_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    biometric_enabled BOOLEAN DEFAULT false,
    pin_enabled BOOLEAN DEFAULT false,
    app_lock_timeout INTEGER DEFAULT 300,
    background_blur_enabled BOOLEAN DEFAULT true,
    two_factor_enabled BOOLEAN DEFAULT false,
    failed_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMPTZ NULL,
    emergency_contact_email TEXT,
    security_score INTEGER DEFAULT 50,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT,
    device_type public.device_type DEFAULT 'mobile'::public.device_type,
    ip_address TEXT,
    user_agent TEXT,
    status public.session_status DEFAULT 'active'::public.session_status,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.security_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_description TEXT,
    ip_address TEXT,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.encrypted_storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    storage_key TEXT NOT NULL,
    encrypted_value TEXT NOT NULL,
    encryption_method TEXT DEFAULT 'AES-256',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, storage_key)
);

CREATE INDEX IF NOT EXISTS idx_security_settings_user_id       ON public.security_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id           ON public.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_device_id         ON public.user_sessions(device_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_status            ON public.user_sessions(status);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at        ON public.user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_user_id      ON public.security_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_event_type   ON public.security_audit_log(event_type);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_created_at   ON public.security_audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_encrypted_storage_user_id       ON public.encrypted_storage(user_id);

CREATE OR REPLACE FUNCTION public.calculate_security_score(user_uuid UUID)
RETURNS INTEGER LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT CASE
    WHEN ss.biometric_enabled AND ss.two_factor_enabled AND ss.pin_enabled THEN 100
    WHEN ss.biometric_enabled AND (ss.two_factor_enabled OR ss.pin_enabled) THEN 85
    WHEN ss.biometric_enabled OR ss.two_factor_enabled THEN 70
    WHEN ss.pin_enabled THEN 60
    ELSE 40
  END FROM public.security_settings ss WHERE ss.user_id = user_uuid LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.log_security_event(
    p_user_id UUID, p_event_type TEXT, p_description TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL, p_user_agent TEXT DEFAULT NULL, p_metadata JSONB DEFAULT '{}')
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE log_id UUID;
BEGIN
  INSERT INTO public.security_audit_log (user_id, event_type, event_description, ip_address, user_agent, metadata)
  VALUES (p_user_id, p_event_type, p_description, p_ip_address, p_user_agent, p_metadata)
  RETURNING id INTO log_id;
  RETURN log_id;
END; $$;

ALTER TABLE public.security_settings   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_audit_log   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.encrypted_storage    ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN CREATE POLICY "users_manage_own_security_settings"   ON public.security_settings   FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "users_manage_own_user_sessions"       ON public.user_sessions        FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "users_view_own_security_audit_log"    ON public.security_audit_log   FOR SELECT TO authenticated USING (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "users_manage_own_encrypted_storage"   ON public.encrypted_storage    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Auto-create security settings for any new user
CREATE OR REPLACE FUNCTION public.handle_new_user_security()
RETURNS TRIGGER SECURITY DEFINER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO public.security_settings (user_id) VALUES (NEW.id) ON CONFLICT (user_id) DO NOTHING;
  PERFORM public.initialize_user_tutorial(NEW.id);
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS on_user_profile_created ON public.user_profiles;
CREATE TRIGGER on_user_profile_created
  AFTER INSERT ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_security();

-- Backfill security_settings for any existing users
INSERT INTO public.security_settings (user_id, security_score)
SELECT id, 50 FROM public.user_profiles
WHERE NOT EXISTS (SELECT 1 FROM public.security_settings ss WHERE ss.user_id = user_profiles.id);


-- ────────────────────────────────────────────────────────────
-- MIGRATION 6 of 6: Scholarships & Applications
-- ────────────────────────────────────────────────────────────

DO $$ BEGIN CREATE TYPE public.scholarship_difficulty AS ENUM ('easy', 'medium', 'hard');               EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.scholarship_status     AS ENUM ('active', 'expired', 'closed');           EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.application_status     AS ENUM ('not_applied', 'applied', 'in_review', 'accepted', 'rejected'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.scholarships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    sponsor TEXT NOT NULL,
    description TEXT NOT NULL,
    award_range_min DECIMAL(10,2),
    award_range_max DECIMAL(10,2),
    award_display TEXT NOT NULL,
    deadline TIMESTAMPTZ NOT NULL,
    application_url TEXT NOT NULL,
    difficulty public.scholarship_difficulty NOT NULL DEFAULT 'medium'::public.scholarship_difficulty,
    status public.scholarship_status NOT NULL DEFAULT 'active'::public.scholarship_status,
    match_percentage INTEGER DEFAULT 0,
    requirements TEXT[] DEFAULT '{}',
    eligibility TEXT[] DEFAULT '{}',
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.scholarship_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    scholarship_id UUID REFERENCES public.scholarships(id) ON DELETE CASCADE,
    status public.application_status NOT NULL DEFAULT 'applied'::public.application_status,
    applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.scholarship_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    scholarship_id UUID REFERENCES public.scholarships(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, scholarship_id)
);

CREATE INDEX IF NOT EXISTS idx_scholarships_deadline ON public.scholarships(deadline);
CREATE INDEX IF NOT EXISTS idx_scholarships_category ON public.scholarships(category);
CREATE INDEX IF NOT EXISTS idx_scholarships_status   ON public.scholarships(status);
CREATE INDEX IF NOT EXISTS idx_scholarship_applications_user_id       ON public.scholarship_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_scholarship_applications_scholarship_id ON public.scholarship_applications(scholarship_id);
CREATE INDEX IF NOT EXISTS idx_scholarship_bookmarks_user_id           ON public.scholarship_bookmarks(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_scholarship_applications_user_scholarship ON public.scholarship_applications(user_id, scholarship_id);

ALTER TABLE public.scholarships              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_applications  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_bookmarks     ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN CREATE POLICY "public_can_read_scholarships"               ON public.scholarships FOR SELECT TO public USING (status = 'active'::public.scholarship_status); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "admin_manage_scholarships"                  ON public.scholarships FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM auth.users au WHERE au.id = auth.uid() AND au.raw_user_meta_data->>'role' = 'admin')) WITH CHECK (EXISTS (SELECT 1 FROM auth.users au WHERE au.id = auth.uid() AND au.raw_user_meta_data->>'role' = 'admin')); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "users_manage_own_scholarship_applications"  ON public.scholarship_applications FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE POLICY "users_manage_own_scholarship_bookmarks"     ON public.scholarship_bookmarks    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid()); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS scholarships_updated_at ON public.scholarships;
CREATE TRIGGER scholarships_updated_at
  BEFORE UPDATE ON public.scholarships FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS scholarship_applications_updated_at ON public.scholarship_applications;
CREATE TRIGGER scholarship_applications_updated_at
  BEFORE UPDATE ON public.scholarship_applications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seed scholarship data
INSERT INTO public.scholarships (title, sponsor, description, award_range_min, award_range_max, award_display, deadline, application_url, difficulty, requirements, eligibility, category, match_percentage)
VALUES
  ('National Merit Scholarship Program', 'National Merit Scholarship Corporation',
   'Recognizes academically talented high school students based on PSAT/NMSQT scores and academic achievement.',
   2500, 10000, '$2,500 – $10,000', NOW() + INTERVAL '120 days', 'https://www.nationalmerit.org', 'hard',
   ARRAY['High PSAT Score','Academic Merit','Essay Required','Transcript Required'],
   ARRAY['High School Senior','Academic Merit','STEM Field'], 'Merit Based', 95),

  ('Gates Millennium Scholars Program', 'Bill & Melinda Gates Foundation',
   'Provides outstanding minority students with opportunities to complete undergraduate and graduate education.',
   5000, 25000, '$5,000 – $25,000', NOW() + INTERVAL '60 days', 'https://gmsp.org', 'hard',
   ARRAY['Financial Need','Essay Required','Letters of Recommendation','Community Service'],
   ARRAY['Minority Student','First Generation','Financial Need'], 'Need Based', 88),

  ('Coca-Cola Scholars Program', 'The Coca-Cola Foundation',
   'Recognizes high school seniors for leadership and commitment to making a significant community impact.',
   20000, 20000, '$20,000', NOW() + INTERVAL '90 days', 'https://www.coca-colascholarsfoundation.org/apply/', 'hard',
   ARRAY['Leadership Experience','Community Service','Essay Required'],
   ARRAY['High School Senior','Leadership Experience'], 'Leadership', 92),

  ('STEM Excellence Scholarship', 'National Science Foundation',
   'Supports students pursuing degrees in Science, Technology, Engineering, and Mathematics.',
   3000, 15000, '$3,000 – $15,000', NOW() + INTERVAL '150 days', 'https://www.nsf.gov', 'medium',
   ARRAY['STEM Field','Academic Merit','Transcript Required'],
   ARRAY['STEM Field','College Freshman','College Sophomore'], 'STEM', 85),

  ('First Generation College Success Grant', 'Education Success Foundation',
   'Supports first-generation college students with financial assistance and mentorship.',
   1500, 5000, '$1,500 – $5,000', NOW() + INTERVAL '75 days', 'https://www.firstgen.org/scholarships', 'easy',
   ARRAY['First Generation','Financial Need','Essay Required'],
   ARRAY['First Generation','Financial Need','High School Senior'], 'First Generation', 78),

  ('Trade Skills Excellence Award', 'National Trade Association',
   'Recognizes students pursuing trade school and vocational training programs.',
   2000, 8000, '$2,000 – $8,000', NOW() + INTERVAL '110 days', 'https://www.skillsusa.org/competitions/scholarships/', 'medium',
   ARRAY['Trade School','Portfolio Required','Skills Assessment'],
   ARRAY['Trade School','High School Senior','Community College'], 'Trade School', 72),

  ('Military Family Education Support', 'Veterans Education Foundation',
   'Provides educational support to children and spouses of active duty military and veterans.',
   1000, 7500, '$1,000 – $7,500', NOW() + INTERVAL '180 days', 'https://www.military.com/education/military-scholarships', 'easy',
   ARRAY['Military Family','Financial Need','Service Documentation'],
   ARRAY['Military Family','High School Senior','College Student'], 'Military', 90),

  ('Women in Technology Scholarship', 'Tech Diversity Initiative',
   'Encourages women to pursue careers in computer science, engineering, and related STEM programs.',
   4000, 12000, '$4,000 – $12,000', NOW() + INTERVAL '45 days', 'https://www.scholarships.com', 'medium',
   ARRAY['STEM Field','Portfolio Required','Interview Required'],
   ARRAY['STEM Field','College Freshman','College Sophomore'], 'Women in STEM', 83),

  ('Healthcare Heroes Scholarship', 'Medical Education Foundation',
   'Recognizes students pursuing healthcare careers with commitment to serving communities.',
   3500, 15000, '$3,500 – $15,000', NOW() + INTERVAL '130 days', 'https://www.nursingscholarships.org/', 'hard',
   ARRAY['Healthcare','Community Service','Letters of Recommendation','Interview Required'],
   ARRAY['Healthcare','College Junior','College Senior','Graduate Student'], 'Healthcare', 87),

  ('Community College Transfer Excellence', 'Transfer Success Network',
   'Supports community college students transferring to four-year institutions.',
   2500, 6000, '$2,500 – $6,000', NOW() + INTERVAL '200 days', 'https://www.scholarships.com', 'easy',
   ARRAY['Community College','Transfer Plans','Academic Merit'],
   ARRAY['Community College','College Sophomore'], 'Transfer', 76)
ON CONFLICT DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- VERIFY: Quick table count check
-- ────────────────────────────────────────────────────────────
DO $$
DECLARE tbl TEXT; cnt INTEGER;
BEGIN
  RAISE NOTICE '=== CollabFuture DB Migration Complete ===';
  FOR tbl IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename LOOP
    EXECUTE format('SELECT COUNT(*) FROM public.%I', tbl) INTO cnt;
    RAISE NOTICE 'Table: %-45s rows: %', tbl, cnt;
  END LOOP;
  RAISE NOTICE '=== Done ===';
END $$;

