-- Location: supabase/migrations/20250919194627_scholarships_and_applications.sql
-- Schema Analysis: Existing user_profiles table with user authentication system
-- Integration Type: Addition - New scholarship management functionality
-- Dependencies: user_profiles (existing table with id UUID PK references auth.users)

-- 1. Create custom types
CREATE TYPE public.scholarship_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE public.scholarship_status AS ENUM ('active', 'expired', 'closed');
CREATE TYPE public.application_status AS ENUM ('not_applied', 'applied', 'in_review', 'accepted', 'rejected');

-- 2. Create scholarships table
CREATE TABLE public.scholarships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    sponsor TEXT NOT NULL,
    description TEXT NOT NULL,
    award_range_min DECIMAL(10,2),
    award_range_max DECIMAL(10,2),
    award_display TEXT NOT NULL, -- Display format like "$2,500 - $10,000"
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

-- 3. Create user scholarship applications tracking table
CREATE TABLE public.scholarship_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    scholarship_id UUID REFERENCES public.scholarships(id) ON DELETE CASCADE,
    status public.application_status NOT NULL DEFAULT 'applied'::public.application_status,
    applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create user bookmarked scholarships table
CREATE TABLE public.scholarship_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    scholarship_id UUID REFERENCES public.scholarships(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, scholarship_id)
);

-- 5. Essential Indexes
CREATE INDEX idx_scholarships_deadline ON public.scholarships(deadline);
CREATE INDEX idx_scholarships_category ON public.scholarships(category);
CREATE INDEX idx_scholarships_status ON public.scholarships(status);
CREATE INDEX idx_scholarship_applications_user_id ON public.scholarship_applications(user_id);
CREATE INDEX idx_scholarship_applications_scholarship_id ON public.scholarship_applications(scholarship_id);
CREATE INDEX idx_scholarship_bookmarks_user_id ON public.scholarship_bookmarks(user_id);
CREATE UNIQUE INDEX idx_scholarship_applications_user_scholarship ON public.scholarship_applications(user_id, scholarship_id);

-- 6. Enable RLS
ALTER TABLE public.scholarships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scholarship_bookmarks ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies

-- Pattern 4: Public Read, Private Write for scholarships (content should be readable by all)
CREATE POLICY "public_can_read_scholarships"
ON public.scholarships
FOR SELECT
TO public
USING (status = 'active'::public.scholarship_status);

CREATE POLICY "admin_manage_scholarships"
ON public.scholarships
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND au.raw_user_meta_data->>'role' = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND au.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Pattern 2: Simple User Ownership for applications
CREATE POLICY "users_manage_own_scholarship_applications"
ON public.scholarship_applications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple User Ownership for bookmarks
CREATE POLICY "users_manage_own_scholarship_bookmarks"
ON public.scholarship_bookmarks
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. Functions for updating timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 9. Triggers for updated_at
CREATE TRIGGER scholarships_updated_at
    BEFORE UPDATE ON public.scholarships
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER scholarship_applications_updated_at
    BEFORE UPDATE ON public.scholarship_applications
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 10. Mock Data
DO $$
DECLARE
    existing_user_id UUID;
    scholarship1_id UUID := gen_random_uuid();
    scholarship2_id UUID := gen_random_uuid();
    scholarship3_id UUID := gen_random_uuid();
    scholarship4_id UUID := gen_random_uuid();
    scholarship5_id UUID := gen_random_uuid();
    scholarship6_id UUID := gen_random_uuid();
    scholarship7_id UUID := gen_random_uuid();
    scholarship8_id UUID := gen_random_uuid();
    scholarship9_id UUID := gen_random_uuid();
    scholarship10_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    -- Create scholarship records with realistic application URLs
    INSERT INTO public.scholarships (
        id, title, sponsor, description, award_range_min, award_range_max, award_display,
        deadline, application_url, difficulty, requirements, eligibility, category, match_percentage
    ) VALUES
        (scholarship1_id, 'National Merit Scholarship Program', 'National Merit Scholarship Corporation',
         'Recognizes academically talented high school students and provides college scholarships based on PSAT/NMSQT scores and academic achievement.',
         2500, 10000, '$2,500 - $10,000',
         '2025-10-15T23:59:59.000Z', 'https://www.nationalmerit.org/s/1758/start.aspx',
         'hard'::public.scholarship_difficulty,
         ARRAY['High PSAT Score', 'Academic Merit', 'Essay Required', 'Transcript Required'],
         ARRAY['High School Senior', 'Academic Merit', 'STEM Field'],
         'Merit Based', 95),

        (scholarship2_id, 'Gates Millennium Scholars Program', 'Bill & Melinda Gates Foundation',
         'Provides outstanding African American, American Indian, Asian Pacific Islander American, and Hispanic American students with opportunities to complete undergraduate and graduate education.',
         5000, 25000, '$5,000 - $25,000',
         '2025-01-15T23:59:59.000Z', 'https://gmsp.org/publicweb/aboutus.cfm',
         'hard'::public.scholarship_difficulty,
         ARRAY['Financial Need', 'Essay Required', 'Letters of Recommendation', 'Community Service'],
         ARRAY['Minority Student', 'First Generation', 'Financial Need'],
         'Need Based', 88),

        (scholarship3_id, 'Coca-Cola Scholars Program', 'The Coca-Cola Foundation',
         'Recognizes high school seniors for their capacity to lead and serve, as well as their commitment to making a significant impact on their schools and communities.',
         20000, 20000, '$20,000',
         '2025-10-31T23:59:59.000Z', 'https://www.coca-colascholarsfoundation.org/apply/',
         'hard'::public.scholarship_difficulty,
         ARRAY['Leadership Experience', 'Community Service', 'Essay Required', 'Academic Merit'],
         ARRAY['High School Senior', 'Leadership Experience', 'Community Service'],
         'Leadership', 92),

        (scholarship4_id, 'STEM Excellence Scholarship', 'National Science Foundation',
         'Supports students pursuing degrees in Science, Technology, Engineering, and Mathematics fields with demonstrated academic excellence and research potential.',
         3000, 15000, '$3,000 - $15,000',
         '2025-03-01T23:59:59.000Z', 'https://www.nsf.gov/funding/pgm_summ.jsp?pims_id=5467',
         'medium'::public.scholarship_difficulty,
         ARRAY['STEM Field', 'Academic Merit', 'Research Experience', 'Transcript Required'],
         ARRAY['STEM Field', 'College Freshman', 'College Sophomore'],
         'STEM', 85),

        (scholarship5_id, 'First Generation College Success Grant', 'Education Success Foundation',
         'Supports first-generation college students in their pursuit of higher education by providing financial assistance and mentorship opportunities.',
         1500, 5000, '$1,500 - $5,000',
         '2025-02-28T23:59:59.000Z', 'https://www.firstgen.org/scholarships',
         'easy'::public.scholarship_difficulty,
         ARRAY['First Generation', 'Financial Need', 'Essay Required'],
         ARRAY['First Generation', 'Financial Need', 'High School Senior'],
         'First Generation', 78),

        (scholarship6_id, 'Trade Skills Excellence Award', 'National Trade Association',
         'Recognizes students pursuing trade school education and vocational training programs with demonstrated skill and commitment to their chosen trade.',
         2000, 8000, '$2,000 - $8,000',
         '2025-04-15T23:59:59.000Z', 'https://www.skillsusa.org/competitions/scholarships/',
         'medium'::public.scholarship_difficulty,
         ARRAY['Trade School', 'Portfolio Required', 'Skills Assessment'],
         ARRAY['Trade School', 'High School Senior', 'Community College'],
         'Trade School', 72),

        (scholarship7_id, 'Military Family Education Support', 'Veterans Education Foundation',
         'Provides educational support to children and spouses of active duty military personnel and veterans pursuing higher education.',
         1000, 7500, '$1,000 - $7,500',
         '2025-05-30T23:59:59.000Z', 'https://www.military.com/education/military-scholarships',
         'easy'::public.scholarship_difficulty,
         ARRAY['Military Family', 'Financial Need', 'Service Documentation'],
         ARRAY['Military Family', 'High School Senior', 'College Student'],
         'Military', 90),

        (scholarship8_id, 'Women in Technology Scholarship', 'Tech Diversity Initiative',
         'Encourages women to pursue careers in technology by providing financial support for computer science, engineering, and related STEM programs.',
         4000, 12000, '$4,000 - $12,000',
         '2025-01-31T23:59:59.000Z', 'https://www.scholarships.com/financial-aid/college-scholarships/scholarships-by-type/minority-scholarships/women-scholarships/',
         'medium'::public.scholarship_difficulty,
         ARRAY['STEM Field', 'Portfolio Required', 'Interview Required'],
         ARRAY['STEM Field', 'College Freshman', 'College Sophomore'],
         'Women in STEM', 83),

        (scholarship9_id, 'Community College Transfer Excellence', 'Transfer Success Network',
         'Supports community college students transferring to four-year institutions with demonstrated academic achievement and clear educational goals.',
         2500, 6000, '$2,500 - $6,000',
         '2025-06-15T23:59:59.000Z', 'https://www.scholarships.com/financial-aid/college-scholarships/scholarships-by-type/transfer-student-scholarships/',
         'easy'::public.scholarship_difficulty,
         ARRAY['Community College', 'Transfer Plans', 'Academic Merit'],
         ARRAY['Community College', 'College Sophomore', 'Transfer Student'],
         'Transfer', 76),

        (scholarship10_id, 'Healthcare Heroes Scholarship', 'Medical Education Foundation',
         'Recognizes students pursuing healthcare careers including nursing, medicine, pharmacy, and allied health professions with commitment to serving communities.',
         3500, 15000, '$3,500 - $15,000',
         '2025-03-15T23:59:59.000Z', 'https://www.nursingscholarships.org/',
         'hard'::public.scholarship_difficulty,
         ARRAY['Healthcare', 'Community Service', 'Letters of Recommendation', 'Interview Required'],
         ARRAY['Healthcare', 'College Junior', 'College Senior', 'Graduate Student'],
         'Healthcare', 87);

    -- Create some sample applications if user exists
    IF existing_user_id IS NOT NULL THEN
        INSERT INTO public.scholarship_applications (user_id, scholarship_id, status, notes)
        VALUES 
            (existing_user_id, scholarship1_id, 'applied'::public.application_status, 'Submitted application with essay'),
            (existing_user_id, scholarship7_id, 'applied'::public.application_status, 'Military background qualifies me for this scholarship');
        
        -- Create some bookmarks
        INSERT INTO public.scholarship_bookmarks (user_id, scholarship_id)
        VALUES 
            (existing_user_id, scholarship2_id),
            (existing_user_id, scholarship4_id),
            (existing_user_id, scholarship10_id);
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;