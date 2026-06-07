-- Location: supabase/migrations/20241220141406151262_calendar_events_enhancement.sql
-- Schema Analysis: Tasks table exists with basic fields, needs calendar-specific enhancements
-- Integration Type: Extension of existing tasks table for calendar events
-- Dependencies: tasks, user_profiles tables (existing)

-- Add new enum type for event types
CREATE TYPE public.event_type AS ENUM ('application', 'scholarship', 'test', 'visit', 'deadline', 'meeting');

-- Add new enum type for assignment targets
CREATE TYPE public.assignment_target AS ENUM ('teen', 'parent', 'both', 'family');

-- Extend existing tasks table with calendar-specific fields
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS event_type public.event_type DEFAULT 'deadline'::public.event_type;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS school_name TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS assigned_to public.assignment_target DEFAULT 'teen'::public.assignment_target;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS is_all_day BOOLEAN DEFAULT false;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS start_time TIME;
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS end_time TIME;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_tasks_event_type ON public.tasks(event_type);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON public.tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_school_name ON public.tasks(school_name) WHERE school_name IS NOT NULL;

-- Add mock calendar events data using existing user references
DO $$
DECLARE
    existing_user_id UUID;
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    -- Only proceed if users exist
    IF existing_user_id IS NOT NULL THEN
        -- Insert calendar-specific events
        INSERT INTO public.tasks (
            user_id, title, description, event_type, school_name, assigned_to,
            priority, status, due_date, location, notes, is_all_day
        ) VALUES
            (existing_user_id, 'Harvard University Application Deadline', 
             'Submit all required documents including essays, transcripts, and recommendations',
             'application'::public.event_type, 'Harvard University', 'teen'::public.assignment_target,
             'high'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '15 days', 'Online Application Portal',
             'Early action deadline - priority application', true),
            
            (existing_user_id, 'Gates Millennium Scholarship Application',
             'Complete scholarship application and submit financial documents',
             'scholarship'::public.event_type, NULL, 'both'::public.assignment_target,
             'high'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '8 days', 'Online Portal',
             'Financial documents required from parents', true),
            
            (existing_user_id, 'SAT Test Date',
             'Arrive at test center by 7:45 AM with admission ticket and ID',
             'test'::public.event_type, NULL, 'teen'::public.assignment_target,
             'high'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '3 days', 'Local Testing Center',
             'Bring calculator and #2 pencils', false),
            
            (existing_user_id, 'MIT Campus Visit',
             'Guided tour at 10 AM, information session at 2 PM',
             'visit'::public.event_type, 'Massachusetts Institute of Technology', 'both'::public.assignment_target,
             'medium'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '22 days', 'MIT Campus, Cambridge MA',
             'Register for tour in advance', false),
            
            (existing_user_id, 'Stanford University Application',
             'Early action deadline - all materials must be submitted',
             'application'::public.event_type, 'Stanford University', 'teen'::public.assignment_target,
             'high'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '45 days', 'Online Application System',
             'Common App supplemental essays required', true),
            
            (existing_user_id, 'Local Community Scholarship',
             'Submit essay on community service impact',
             'scholarship'::public.event_type, 'Community Foundation', 'teen'::public.assignment_target,
             'medium'::public.task_priority, 'completed'::public.task_status,
             CURRENT_DATE + INTERVAL '12 days', 'Online Submission',
             'Essay should be 500 words maximum', true),
            
            (existing_user_id, 'UC Berkeley Campus Tour',
             'Self-guided tour and meeting with admissions counselor',
             'visit'::public.event_type, 'University of California, Berkeley', 'both'::public.assignment_target,
             'low'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '35 days', 'UC Berkeley Campus',
             'Schedule meeting with engineering department', false),
            
            (existing_user_id, 'ACT Test Registration Deadline',
             'Register for December ACT test date',
             'deadline'::public.event_type, NULL, 'parent'::public.assignment_target,
             'medium'::public.task_priority, 'pending'::public.task_status,
             CURRENT_DATE + INTERVAL '5 days', 'Online Registration',
             'Payment required at registration', true);
    ELSE
        RAISE NOTICE 'No existing users found. Please run auth migration first or create users manually.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;