-- Location: supabase/migrations/20250919134716_security_features.sql
-- Schema Analysis: Existing user_profiles table with basic auth, subscription system exists
-- Integration Type: Additive - Adding security features and session management
-- Dependencies: user_profiles (existing table with id, email, role columns)

-- 1. Security-related ENUMs and types
CREATE TYPE public.session_status AS ENUM ('active', 'expired', 'revoked', 'suspicious');
CREATE TYPE public.auth_method AS ENUM ('password', 'biometric', 'pin', 'pattern');
CREATE TYPE public.device_type AS ENUM ('mobile', 'tablet', 'desktop', 'web');

-- 2. Security settings table to extend user_profiles
CREATE TABLE public.security_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    biometric_enabled BOOLEAN DEFAULT false,
    pin_enabled BOOLEAN DEFAULT false,
    app_lock_timeout INTEGER DEFAULT 300, -- in seconds (5 minutes default)
    background_blur_enabled BOOLEAN DEFAULT true,
    two_factor_enabled BOOLEAN DEFAULT false,
    failed_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMPTZ NULL,
    emergency_contact_email TEXT,
    security_score INTEGER DEFAULT 50, -- out of 100
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 3. User sessions table for session management
CREATE TABLE public.user_sessions (
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

-- 4. Security audit log table
CREATE TABLE public.security_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, -- 'login', 'logout', 'failed_attempt', 'settings_change', etc.
    event_description TEXT,
    ip_address TEXT,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Encrypted storage settings table  
CREATE TABLE public.encrypted_storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    storage_key TEXT NOT NULL,
    encrypted_value TEXT NOT NULL,
    encryption_method TEXT DEFAULT 'AES-256',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, storage_key)
);

-- 6. Essential indexes for performance
CREATE INDEX idx_security_settings_user_id ON public.security_settings(user_id);
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_user_sessions_device_id ON public.user_sessions(device_id);
CREATE INDEX idx_user_sessions_status ON public.user_sessions(status);
CREATE INDEX idx_user_sessions_expires_at ON public.user_sessions(expires_at);
CREATE INDEX idx_security_audit_log_user_id ON public.security_audit_log(user_id);
CREATE INDEX idx_security_audit_log_event_type ON public.security_audit_log(event_type);
CREATE INDEX idx_security_audit_log_created_at ON public.security_audit_log(created_at);
CREATE INDEX idx_encrypted_storage_user_id ON public.encrypted_storage(user_id);

-- 7. Security helper functions (BEFORE RLS policies)
CREATE OR REPLACE FUNCTION public.calculate_security_score(user_uuid UUID)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
  CASE
    WHEN ss.biometric_enabled AND ss.two_factor_enabled AND ss.pin_enabled THEN 100
    WHEN ss.biometric_enabled AND (ss.two_factor_enabled OR ss.pin_enabled) THEN 85
    WHEN ss.biometric_enabled OR ss.two_factor_enabled THEN 70
    WHEN ss.pin_enabled THEN 60
    ELSE 40
  END
FROM public.security_settings ss
WHERE ss.user_id = user_uuid
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.cleanup_expired_sessions()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    -- Update expired sessions
    UPDATE public.user_sessions 
    SET status = 'expired'::public.session_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE expires_at < CURRENT_TIMESTAMP 
    AND status = 'active'::public.session_status;
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    
    -- Log cleanup activity
    INSERT INTO public.security_audit_log (event_type, event_description, metadata)
    VALUES ('session_cleanup', 'Automated session cleanup', 
            json_build_object('expired_sessions', expired_count));
    
    RETURN expired_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_security_event(
    p_user_id UUID,
    p_event_type TEXT,
    p_description TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    log_id UUID;
BEGIN
    INSERT INTO public.security_audit_log (
        user_id, event_type, event_description, ip_address, user_agent, metadata
    ) VALUES (
        p_user_id, p_event_type, p_description, p_ip_address, p_user_agent, p_metadata
    ) RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$;

-- 8. Enable RLS on all security tables
ALTER TABLE public.security_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.encrypted_storage ENABLE ROW LEVEL SECURITY;

-- 9. RLS Policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_security_settings"
ON public.security_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_sessions"
ON public.user_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_own_security_audit_log"
ON public.security_audit_log
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "users_manage_own_encrypted_storage"
ON public.encrypted_storage
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 10. Create default security settings for existing users
INSERT INTO public.security_settings (user_id, security_score)
SELECT id, 50 
FROM public.user_profiles up
WHERE NOT EXISTS (
    SELECT 1 FROM public.security_settings ss WHERE ss.user_id = up.id
);

-- 11. Mock security data for testing
DO $$
DECLARE
    existing_user_id UUID;
    session_id UUID := gen_random_uuid();
BEGIN
    -- Get an existing user ID
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Create sample session
        INSERT INTO public.user_sessions (
            id, user_id, device_id, device_name, device_type, ip_address, status
        ) VALUES (
            session_id, existing_user_id, 'device_001', 'iPhone 15', 'mobile'::public.device_type,
            '192.168.1.100', 'active'::public.session_status
        );
        
        -- Create sample audit log entries
        INSERT INTO public.security_audit_log (user_id, event_type, event_description, ip_address)
        VALUES 
            (existing_user_id, 'login', 'User logged in successfully', '192.168.1.100'),
            (existing_user_id, 'settings_change', 'Enabled biometric authentication', '192.168.1.100'),
            (existing_user_id, 'failed_attempt', 'Failed authentication attempt', '192.168.1.50');
        
        -- Update security settings for existing user
        UPDATE public.security_settings 
        SET biometric_enabled = true, 
            security_score = 85,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = existing_user_id;
    ELSE
        RAISE NOTICE 'No existing users found. Create users first.';
    END IF;
END $$;