--
-- PostgreSQL database dump
--

\restrict 3zXGE9DiGesSMTwNf17hNn9OMEThS3dxeS6Ahy9fURTchbxzEV0Yvbt7EeHc2U3

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid DEFAULT '00000000-0000-0000-0000-000000000001'::uuid NOT NULL,
    user_id uuid,
    event_type text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    ip_address text,
    user_agent text,
    details jsonb,
    severity text DEFAULT 'INFORMATIONAL'::text NOT NULL,
    expires_at timestamp with time zone,
    is_anomaly boolean DEFAULT false
);


ALTER TABLE public.activity_logs OWNER TO postgres;

--
-- Name: admin_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    email text,
    password_hash text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    last_login_at timestamp with time zone,
    two_fa_enabled boolean DEFAULT false,
    two_fa_method character varying(20),
    two_fa_secret text,
    two_fa_recovery_codes jsonb,
    magic_link_enabled boolean DEFAULT false,
    backup_email character varying(255) DEFAULT ''::character varying,
    backup_email_verified boolean DEFAULT false
);


ALTER TABLE public.admin_accounts OWNER TO postgres;

--
-- Name: api_key_usages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_key_usages (
    id bigint NOT NULL,
    api_key_id uuid NOT NULL,
    period_date date NOT NULL,
    request_count bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.api_key_usages OWNER TO postgres;

--
-- Name: api_key_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.api_key_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.api_key_usages_id_seq OWNER TO postgres;

--
-- Name: api_key_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.api_key_usages_id_seq OWNED BY public.api_key_usages.id;


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key_type text NOT NULL,
    name text NOT NULL,
    description text,
    key_hash text NOT NULL,
    key_prefix text NOT NULL,
    key_suffix text NOT NULL,
    scopes text DEFAULT ''::text,
    app_id uuid,
    expires_at timestamp with time zone,
    last_used_at timestamp with time zone,
    is_revoked boolean DEFAULT false,
    notified7_days_at timestamp with time zone,
    notified1_day_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.api_keys OWNER TO postgres;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    two_fa_issuer_name text DEFAULT ''::text,
    two_fa_enabled boolean DEFAULT true,
    two_fa_required boolean DEFAULT false,
    email2_fa_enabled boolean DEFAULT false,
    passkey2_fa_enabled boolean DEFAULT false,
    passkey_login_enabled boolean DEFAULT false,
    magic_link_enabled boolean DEFAULT false,
    two_fa_methods character varying(100) DEFAULT 'totp'::character varying,
    login_notifications_enabled boolean DEFAULT false,
    suspicious_activity_alerts boolean DEFAULT false,
    sms2_fa_enabled boolean DEFAULT false,
    trusted_device_enabled boolean DEFAULT false,
    trusted_device_max_days bigint DEFAULT 30,
    bf_lockout_enabled boolean,
    bf_lockout_threshold bigint,
    bf_lockout_durations character varying(255) DEFAULT NULL::character varying,
    bf_lockout_window character varying(50) DEFAULT NULL::character varying,
    bf_lockout_tier_ttl character varying(50) DEFAULT NULL::character varying,
    bf_delay_enabled boolean,
    bf_delay_start_after bigint,
    bf_delay_max_seconds bigint,
    bf_delay_tier_ttl character varying(50) DEFAULT NULL::character varying,
    bf_captcha_enabled boolean,
    bf_captcha_site_key character varying(500) DEFAULT NULL::character varying,
    bf_captcha_secret_key character varying(500) DEFAULT NULL::character varying,
    bf_captcha_threshold bigint,
    frontend_url character varying(500) DEFAULT ''::character varying,
    reset_password_path character varying(500) DEFAULT ''::character varying,
    magic_link_path character varying(500) DEFAULT ''::character varying,
    verify_email_path character varying(500) DEFAULT ''::character varying,
    oidc_enabled boolean DEFAULT false,
    oidc_rsa_private_key text DEFAULT ''::text,
    oidc_id_token_ttl bigint DEFAULT 3600,
    oidc_issuer_url character varying(500) DEFAULT ''::character varying,
    login_logo_url character varying(500) DEFAULT ''::character varying,
    login_theme character varying(20) DEFAULT 'auto'::character varying,
    login_primary_color character varying(20) DEFAULT ''::character varying,
    login_secondary_color character varying(20) DEFAULT ''::character varying,
    login_display_name character varying(200) DEFAULT ''::character varying,
    pw_min_length bigint DEFAULT 8,
    pw_max_length bigint DEFAULT 128,
    pw_require_upper boolean DEFAULT false,
    pw_require_lower boolean DEFAULT false,
    pw_require_digit boolean DEFAULT false,
    pw_require_symbol boolean DEFAULT false,
    pw_history_count bigint DEFAULT 0,
    pw_max_age_days bigint DEFAULT 0,
    access_token_ttl_minutes bigint DEFAULT 0,
    refresh_token_ttl_hours bigint DEFAULT 0,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: email_server_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_server_configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid,
    name character varying(100) DEFAULT 'Default'::character varying NOT NULL,
    smtp_host character varying(255) NOT NULL,
    smtp_port bigint DEFAULT 587 NOT NULL,
    smtp_username character varying(255),
    smtp_password text,
    from_address character varying(255) NOT NULL,
    from_name character varying(100),
    use_tls boolean DEFAULT true,
    is_default boolean DEFAULT true,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.email_server_configs OWNER TO postgres;

--
-- Name: email_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid,
    email_type_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    subject character varying(255) NOT NULL,
    body_html text,
    body_text text,
    template_engine character varying(20) DEFAULT 'go_template'::character varying NOT NULL,
    from_email character varying(255) DEFAULT ''::character varying,
    from_name character varying(255) DEFAULT ''::character varying,
    server_config_id uuid,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.email_templates OWNER TO postgres;

--
-- Name: email_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    default_subject character varying(255),
    variables jsonb,
    is_system boolean DEFAULT true,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.email_types OWNER TO postgres;

--
-- Name: ip_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid NOT NULL,
    rule_type character varying(10) NOT NULL,
    match_type character varying(10) NOT NULL,
    value text NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.ip_rules OWNER TO postgres;

--
-- Name: o_id_c_auth_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.o_id_c_auth_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid NOT NULL,
    client_id text NOT NULL,
    user_id uuid NOT NULL,
    code text NOT NULL,
    redirect_uri text NOT NULL,
    scopes text NOT NULL,
    nonce text DEFAULT ''::text,
    code_challenge text DEFAULT ''::text,
    code_challenge_method text DEFAULT ''::text,
    expires_at timestamp with time zone NOT NULL,
    used boolean DEFAULT false,
    created_at timestamp with time zone
);


ALTER TABLE public.o_id_c_auth_codes OWNER TO postgres;

--
-- Name: o_id_c_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.o_id_c_clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    redirect_uris text DEFAULT '[]'::text NOT NULL,
    allowed_grant_types character varying(200) DEFAULT 'authorization_code,refresh_token'::character varying,
    allowed_scopes character varying(200) DEFAULT 'openid profile email'::character varying,
    require_consent boolean DEFAULT true,
    is_confidential boolean DEFAULT true,
    pkce_required boolean DEFAULT false,
    logo_url text DEFAULT ''::text,
    login_theme character varying(20) DEFAULT 'auto'::character varying,
    login_primary_color character varying(20) DEFAULT ''::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.o_id_c_clients OWNER TO postgres;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource text NOT NULL,
    action text NOT NULL,
    description text,
    created_at timestamp with time zone
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    is_system boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    id bigint NOT NULL,
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    execution_time_ms bigint,
    success boolean DEFAULT true NOT NULL,
    error_message text,
    checksum character varying(64)
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schema_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schema_migrations_id_seq OWNER TO postgres;

--
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schema_migrations_id_seq OWNED BY public.schema_migrations.id;


--
-- Name: session_group_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_group_apps (
    session_group_id uuid NOT NULL,
    app_id uuid NOT NULL,
    added_at timestamp with time zone
);


ALTER TABLE public.session_group_apps OWNER TO postgres;

--
-- Name: session_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    global_logout boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.session_groups OWNER TO postgres;

--
-- Name: social_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.social_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid DEFAULT '00000000-0000-0000-0000-000000000001'::uuid NOT NULL,
    user_id uuid NOT NULL,
    provider text NOT NULL,
    provider_user_id text NOT NULL,
    email text,
    name text,
    first_name text,
    last_name text,
    profile_picture text,
    username text,
    locale text,
    raw_data jsonb,
    access_token text,
    refresh_token text,
    expires_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.social_accounts OWNER TO postgres;

--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_settings (
    key character varying(100) NOT NULL,
    value text NOT NULL,
    category character varying(50) NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.system_settings OWNER TO postgres;

--
-- Name: trusted_devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trusted_devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    app_id uuid NOT NULL,
    token_hash character varying(64) NOT NULL,
    name character varying(255),
    user_agent text,
    ip_address character varying(45),
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone,
    created_at timestamp with time zone
);


ALTER TABLE public.trusted_devices OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    app_id uuid NOT NULL,
    assigned_at timestamp with time zone,
    assigned_by uuid
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid DEFAULT '00000000-0000-0000-0000-000000000001'::uuid NOT NULL,
    email text NOT NULL,
    password_hash text,
    email_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    name text,
    first_name text,
    last_name text,
    profile_picture text,
    locale text,
    two_fa_enabled boolean DEFAULT false,
    two_fa_method character varying(20) DEFAULT ''::character varying,
    two_fa_secret text,
    two_fa_recovery_codes jsonb,
    backup_email character varying(255) DEFAULT ''::character varying,
    backup_email_verified boolean DEFAULT false,
    two_fa_previous_method character varying(20) DEFAULT ''::character varying,
    two_fa_previous_secret text DEFAULT ''::text,
    phone_number character varying(30) DEFAULT ''::character varying,
    phone_verified boolean DEFAULT false,
    locked_at timestamp with time zone,
    lock_reason character varying(255) DEFAULT ''::character varying,
    lock_expires_at timestamp with time zone,
    password_history jsonb DEFAULT '[]'::jsonb,
    password_changed_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: web_authn_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.web_authn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    app_id uuid,
    admin_id uuid,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type character varying(50),
    aa_guid bytea,
    sign_count bigint DEFAULT 0,
    name character varying(100),
    transports character varying(255),
    backup_eligible boolean DEFAULT false,
    backup_state boolean DEFAULT false,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone
);


ALTER TABLE public.web_authn_credentials OWNER TO postgres;

--
-- Name: webhook_deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webhook_deliveries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    endpoint_id uuid NOT NULL,
    app_id uuid NOT NULL,
    event_type text NOT NULL,
    payload text NOT NULL,
    attempt bigint DEFAULT 1 NOT NULL,
    status_code bigint,
    response_body text,
    latency_ms bigint,
    success boolean DEFAULT false NOT NULL,
    error_message text,
    next_retry_at timestamp with time zone,
    created_at timestamp with time zone
);


ALTER TABLE public.webhook_deliveries OWNER TO postgres;

--
-- Name: webhook_endpoints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webhook_endpoints (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    app_id uuid NOT NULL,
    event_type text NOT NULL,
    url text NOT NULL,
    secret text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.webhook_endpoints OWNER TO postgres;

--
-- Name: api_key_usages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_key_usages ALTER COLUMN id SET DEFAULT nextval('public.api_key_usages_id_seq'::regclass);


--
-- Name: schema_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.schema_migrations_id_seq'::regclass);


--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_logs (id, app_id, user_id, event_type, "timestamp", ip_address, user_agent, details, severity, expires_at, is_anomaly) FROM stdin;
\.


--
-- Data for Name: admin_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_accounts (id, username, email, password_hash, created_at, updated_at, last_login_at, two_fa_enabled, two_fa_method, two_fa_secret, two_fa_recovery_codes, magic_link_enabled, backup_email, backup_email_verified) FROM stdin;
\.


--
-- Data for Name: api_key_usages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_key_usages (id, api_key_id, period_date, request_count, updated_at) FROM stdin;
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key_type, name, description, key_hash, key_prefix, key_suffix, scopes, app_id, expires_at, last_used_at, is_revoked, notified7_days_at, notified1_day_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, tenant_id, name, description, two_fa_issuer_name, two_fa_enabled, two_fa_required, email2_fa_enabled, passkey2_fa_enabled, passkey_login_enabled, magic_link_enabled, two_fa_methods, login_notifications_enabled, suspicious_activity_alerts, sms2_fa_enabled, trusted_device_enabled, trusted_device_max_days, bf_lockout_enabled, bf_lockout_threshold, bf_lockout_durations, bf_lockout_window, bf_lockout_tier_ttl, bf_delay_enabled, bf_delay_start_after, bf_delay_max_seconds, bf_delay_tier_ttl, bf_captcha_enabled, bf_captcha_site_key, bf_captcha_secret_key, bf_captcha_threshold, frontend_url, reset_password_path, magic_link_path, verify_email_path, oidc_enabled, oidc_rsa_private_key, oidc_id_token_ttl, oidc_issuer_url, login_logo_url, login_theme, login_primary_color, login_secondary_color, login_display_name, pw_min_length, pw_max_length, pw_require_upper, pw_require_lower, pw_require_digit, pw_require_symbol, pw_history_count, pw_max_age_days, access_token_ttl_minutes, refresh_token_ttl_hours, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_server_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_server_configs (id, app_id, name, smtp_host, smtp_port, smtp_username, smtp_password, from_address, from_name, use_tls, is_default, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_templates (id, app_id, email_type_id, name, subject, body_html, body_text, template_engine, from_email, from_name, server_config_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_types (id, code, name, description, default_subject, variables, is_system, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ip_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ip_rules (id, app_id, rule_type, match_type, value, description, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: o_id_c_auth_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.o_id_c_auth_codes (id, app_id, client_id, user_id, code, redirect_uri, scopes, nonce, code_challenge, code_challenge_method, expires_at, used, created_at) FROM stdin;
\.


--
-- Data for Name: o_id_c_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.o_id_c_clients (id, app_id, name, description, client_id, client_secret_hash, redirect_uris, allowed_grant_types, allowed_scopes, require_consent, is_confidential, pkce_required, logo_url, login_theme, login_primary_color, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, resource, action, description, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, app_id, name, description, is_system, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (id, version, name, applied_at, execution_time_ms, success, error_message, checksum) FROM stdin;
\.


--
-- Data for Name: session_group_apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_group_apps (session_group_id, app_id, added_at) FROM stdin;
\.


--
-- Data for Name: session_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_groups (id, tenant_id, name, description, global_logout, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: social_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.social_accounts (id, app_id, user_id, provider, provider_user_id, email, name, first_name, last_name, profile_picture, username, locale, raw_data, access_token, refresh_token, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_settings (key, value, category, updated_at) FROM stdin;
\.


--
-- Data for Name: trusted_devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trusted_devices (id, user_id, app_id, token_hash, name, user_agent, ip_address, last_used_at, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (user_id, role_id, app_id, assigned_at, assigned_by) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, app_id, email, password_hash, email_verified, is_active, name, first_name, last_name, profile_picture, locale, two_fa_enabled, two_fa_method, two_fa_secret, two_fa_recovery_codes, backup_email, backup_email_verified, two_fa_previous_method, two_fa_previous_secret, phone_number, phone_verified, locked_at, lock_reason, lock_expires_at, password_history, password_changed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: web_authn_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.web_authn_credentials (id, user_id, app_id, admin_id, credential_id, public_key, attestation_type, aa_guid, sign_count, name, transports, backup_eligible, backup_state, last_used_at, created_at) FROM stdin;
\.


--
-- Data for Name: webhook_deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.webhook_deliveries (id, endpoint_id, app_id, event_type, payload, attempt, status_code, response_body, latency_ms, success, error_message, next_retry_at, created_at) FROM stdin;
\.


--
-- Data for Name: webhook_endpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.webhook_endpoints (id, app_id, event_type, url, secret, is_active, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Name: api_key_usages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_key_usages_id_seq', 1, false);


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_migrations_id_seq', 1, false);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_accounts admin_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_accounts
    ADD CONSTRAINT admin_accounts_pkey PRIMARY KEY (id);


--
-- Name: api_key_usages api_key_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_key_usages
    ADD CONSTRAINT api_key_usages_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: email_server_configs email_server_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_server_configs
    ADD CONSTRAINT email_server_configs_pkey PRIMARY KEY (id);


--
-- Name: email_templates email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: email_types email_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_types
    ADD CONSTRAINT email_types_pkey PRIMARY KEY (id);


--
-- Name: ip_rules ip_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_rules
    ADD CONSTRAINT ip_rules_pkey PRIMARY KEY (id);


--
-- Name: o_id_c_auth_codes o_id_c_auth_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.o_id_c_auth_codes
    ADD CONSTRAINT o_id_c_auth_codes_pkey PRIMARY KEY (id);


--
-- Name: o_id_c_clients o_id_c_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.o_id_c_clients
    ADD CONSTRAINT o_id_c_clients_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: session_group_apps session_group_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_group_apps
    ADD CONSTRAINT session_group_apps_pkey PRIMARY KEY (session_group_id, app_id);


--
-- Name: session_groups session_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_groups
    ADD CONSTRAINT session_groups_pkey PRIMARY KEY (id);


--
-- Name: social_accounts social_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (key);


--
-- Name: trusted_devices trusted_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trusted_devices
    ADD CONSTRAINT trusted_devices_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: web_authn_credentials web_authn_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_authn_credentials
    ADD CONSTRAINT web_authn_credentials_pkey PRIMARY KEY (id);


--
-- Name: webhook_deliveries webhook_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_pkey PRIMARY KEY (id);


--
-- Name: webhook_endpoints webhook_endpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook_endpoints
    ADD CONSTRAINT webhook_endpoints_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_logs_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_logs_app_id ON public.activity_logs USING btree (app_id);


--
-- Name: idx_activity_logs_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_logs_event_type ON public.activity_logs USING btree (event_type);


--
-- Name: idx_admin_accounts_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admin_accounts_email ON public.admin_accounts USING btree (email);


--
-- Name: idx_admin_accounts_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admin_accounts_username ON public.admin_accounts USING btree (username);


--
-- Name: idx_api_key_usage_key_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_api_key_usage_key_period ON public.api_key_usages USING btree (api_key_id, period_date);


--
-- Name: idx_api_keys_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_app_id ON public.api_keys USING btree (app_id);


--
-- Name: idx_api_keys_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_expires_at ON public.api_keys USING btree (expires_at);


--
-- Name: idx_api_keys_is_revoked; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_is_revoked ON public.api_keys USING btree (is_revoked);


--
-- Name: idx_api_keys_key_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_api_keys_key_hash ON public.api_keys USING btree (key_hash);


--
-- Name: idx_api_keys_key_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_key_type ON public.api_keys USING btree (key_type);


--
-- Name: idx_app_email_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_email_type ON public.email_templates USING btree (app_id, email_type_id);


--
-- Name: idx_applications_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_tenant_id ON public.applications USING btree (tenant_id);


--
-- Name: idx_cleanup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cleanup ON public.activity_logs USING btree (user_id, "timestamp", severity);


--
-- Name: idx_email_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_email_app_id ON public.users USING btree (app_id, email);


--
-- Name: idx_email_server_configs_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_email_server_configs_app_id ON public.email_server_configs USING btree (app_id);


--
-- Name: idx_email_templates_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_email_templates_app_id ON public.email_templates USING btree (app_id);


--
-- Name: idx_email_types_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_email_types_code ON public.email_types USING btree (code);


--
-- Name: idx_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_expires ON public.activity_logs USING btree (expires_at);


--
-- Name: idx_ip_rule_app; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ip_rule_app ON public.ip_rules USING btree (app_id);


--
-- Name: idx_o_id_c_auth_codes_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_o_id_c_auth_codes_app_id ON public.o_id_c_auth_codes USING btree (app_id);


--
-- Name: idx_o_id_c_auth_codes_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_o_id_c_auth_codes_client_id ON public.o_id_c_auth_codes USING btree (client_id);


--
-- Name: idx_o_id_c_auth_codes_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_o_id_c_auth_codes_code ON public.o_id_c_auth_codes USING btree (code);


--
-- Name: idx_o_id_c_auth_codes_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_o_id_c_auth_codes_expires_at ON public.o_id_c_auth_codes USING btree (expires_at);


--
-- Name: idx_o_id_c_clients_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_o_id_c_clients_app_id ON public.o_id_c_clients USING btree (app_id);


--
-- Name: idx_o_id_c_clients_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_o_id_c_clients_client_id ON public.o_id_c_clients USING btree (client_id);


--
-- Name: idx_permission_resource_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_permission_resource_action ON public.permissions USING btree (resource, action);


--
-- Name: idx_provider_user_id_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_provider_user_id_app_id ON public.social_accounts USING btree (app_id, provider, provider_user_id);


--
-- Name: idx_role_app_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_role_app_name ON public.roles USING btree (app_id, name);


--
-- Name: idx_roles_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_roles_app_id ON public.roles USING btree (app_id);


--
-- Name: idx_schema_migrations_applied_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schema_migrations_applied_at ON public.schema_migrations USING btree (applied_at);


--
-- Name: idx_schema_migrations_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_schema_migrations_version ON public.schema_migrations USING btree (version);


--
-- Name: idx_session_group_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_session_group_app_id ON public.session_group_apps USING btree (app_id);


--
-- Name: idx_session_groups_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_session_groups_tenant_id ON public.session_groups USING btree (tenant_id);


--
-- Name: idx_social_accounts_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_social_accounts_app_id ON public.social_accounts USING btree (app_id);


--
-- Name: idx_social_accounts_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_social_accounts_provider ON public.social_accounts USING btree (provider);


--
-- Name: idx_social_accounts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_social_accounts_user_id ON public.social_accounts USING btree (user_id);


--
-- Name: idx_system_settings_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_system_settings_category ON public.system_settings USING btree (category);


--
-- Name: idx_trusted_device_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trusted_device_expires ON public.trusted_devices USING btree (expires_at);


--
-- Name: idx_trusted_device_user_app; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trusted_device_user_app ON public.trusted_devices USING btree (user_id, app_id);


--
-- Name: idx_trusted_devices_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_trusted_devices_token_hash ON public.trusted_devices USING btree (token_hash);


--
-- Name: idx_user_role_app_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_role_app_user ON public.user_roles USING btree (app_id);


--
-- Name: idx_user_roles_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_roles_app_id ON public.user_roles USING btree (app_id);


--
-- Name: idx_user_roles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_roles_user_id ON public.user_roles USING btree (user_id);


--
-- Name: idx_user_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_timestamp ON public.activity_logs USING btree (user_id, "timestamp");


--
-- Name: idx_users_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_app_id ON public.users USING btree (app_id);


--
-- Name: idx_web_authn_credentials_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_web_authn_credentials_admin_id ON public.web_authn_credentials USING btree (admin_id);


--
-- Name: idx_web_authn_credentials_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_web_authn_credentials_app_id ON public.web_authn_credentials USING btree (app_id);


--
-- Name: idx_web_authn_credentials_credential_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_web_authn_credentials_credential_id ON public.web_authn_credentials USING btree (credential_id);


--
-- Name: idx_web_authn_credentials_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_web_authn_credentials_user_id ON public.web_authn_credentials USING btree (user_id);


--
-- Name: idx_webhook_app_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_webhook_app_event ON public.webhook_endpoints USING btree (app_id, event_type);


--
-- Name: idx_webhook_deliveries_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_deliveries_app_id ON public.webhook_deliveries USING btree (app_id);


--
-- Name: idx_webhook_deliveries_endpoint_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_deliveries_endpoint_id ON public.webhook_deliveries USING btree (endpoint_id);


--
-- Name: idx_webhook_deliveries_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_deliveries_event_type ON public.webhook_deliveries USING btree (event_type);


--
-- Name: idx_webhook_deliveries_next_retry_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_deliveries_next_retry_at ON public.webhook_deliveries USING btree (next_retry_at);


--
-- Name: idx_webhook_deliveries_success; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_deliveries_success ON public.webhook_deliveries USING btree (success);


--
-- Name: idx_webhook_endpoints_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_webhook_endpoints_deleted_at ON public.webhook_endpoints USING btree (deleted_at);


--
-- Name: api_keys fk_api_keys_application; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT fk_api_keys_application FOREIGN KEY (app_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: email_server_configs fk_applications_email_server_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_server_configs
    ADD CONSTRAINT fk_applications_email_server_config FOREIGN KEY (app_id) REFERENCES public.applications(id);


--
-- Name: o_id_c_clients fk_applications_o_id_c_clients; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.o_id_c_clients
    ADD CONSTRAINT fk_applications_o_id_c_clients FOREIGN KEY (app_id) REFERENCES public.applications(id);


--
-- Name: email_templates fk_email_templates_email_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT fk_email_templates_email_type FOREIGN KEY (email_type_id) REFERENCES public.email_types(id);


--
-- Name: email_templates fk_email_templates_server_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_templates
    ADD CONSTRAINT fk_email_templates_server_config FOREIGN KEY (server_config_id) REFERENCES public.email_server_configs(id);


--
-- Name: role_permissions fk_role_permissions_permission; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: role_permissions fk_role_permissions_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: session_group_apps fk_session_group_apps_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_group_apps
    ADD CONSTRAINT fk_session_group_apps_app FOREIGN KEY (app_id) REFERENCES public.applications(id);


--
-- Name: session_group_apps fk_session_groups_apps; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_group_apps
    ADD CONSTRAINT fk_session_groups_apps FOREIGN KEY (session_group_id) REFERENCES public.session_groups(id);


--
-- Name: user_roles fk_user_roles_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles fk_user_roles_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: social_accounts fk_users_social_accounts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT fk_users_social_accounts FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: webhook_deliveries fk_webhook_deliveries_endpoint; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT fk_webhook_deliveries_endpoint FOREIGN KEY (endpoint_id) REFERENCES public.webhook_endpoints(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 3zXGE9DiGesSMTwNf17hNn9OMEThS3dxeS6Ahy9fURTchbxzEV0Yvbt7EeHc2U3

