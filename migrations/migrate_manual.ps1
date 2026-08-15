cd C:\Users\ith\Desktop\golang-auth-api\migrations

echo Migrate de todas tabelas

REM
psql -U postgres -d auth_db -f  00_create_migrations_table.sql

REM
pause
psql -U postgres -d auth_db -f  00_create_migrations_table_rollback.sql

REM
psql -U postgres -d auth_db -f  20240103_add_activity_log_smart_fields.sql


REM
psql -U postgres -d auth_db -f  20240103_add_activity_log_smart_fields_rollback.sql

REM
pause
psql -U postgres -d auth_db -f  20260105_add_multi_tenancy.sql

REM
pause
psql -U postgres -d auth_db -f  20260105_add_multi_tenancy_rollback.sql

REM
pause
psql -U postgres -d auth_db -f  20260120_fix_social_account_unique_index.sql

REM
pause
psql -U postgres -d auth_db -f  20260220_add_admin_accounts.sql

REM
pause
psql -U postgres -d auth_db -f  20260220_add_admin_accounts_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260220_add_api_keys.sql

REM
psql -U postgres -d auth_db -f  20260220_add_api_keys_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260220_add_user_is_active.sql

REM
psql -U postgres -d auth_db -f  20260220_add_user_is_active_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260221_add_system_settings.sql
pause

REM
psql -U postgres -d auth_db -f  20260221_add_system_settings_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260221_fix_activity_log_user_id_type.sql
pause

REM
psql -U postgres -d auth_db -f  20260221_fix_activity_log_user_id_type_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260222_add_app_twofa_settings.sql
pause

REM
psql -U postgres -d auth_db -f  20260222_add_app_twofa_settings_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260222_add_email_2fa_settings.sql

REM
psql -U postgres -d auth_db -f  20260222_add_email_2fa_settings_rollback.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260222_add_email_system.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260222_add_email_system_rollback.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260222_seed_default_email_templates.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260222_seed_default_email_templates_rollback.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260223_add_multi_sender_support.sql


REM
psql -U postgres -d auth_db -f  20260223_add_multi_sender_support_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260226_add_admin_2fa.sql

REM

REM
psql -U postgres -d auth_db -f  20260226_add_admin_2fa_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260227_add_global_smtp_config.sql

REM

REM
psql -U postgres -d auth_db -f  20260227_add_global_smtp_config_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260301_add_rbac.sql

REM

REM
psql -U postgres -d auth_db -f  20260301_add_rbac_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260301_seed_rbac_defaults.sql


REM

REM
psql -U postgres -d auth_db -f  20260301_seed_rbac_defaults_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260302_backfill_member_role.sql

REM

REM
psql -U postgres -d auth_db -f  20260302_backfill_member_role_rollback.sql


REM
psql -U postgres -d auth_db -f  20260303_add_admin_magic_link.sql


REM
sql -U postgres -d auth_db -f  20260303_add_admin_magic_link_rollback.sql


REM
psql -U postgres -d auth_db -f  20260303_add_magic_link_settings.sql


REM
psql -U postgres -d auth_db -f  20260303_add_magic_link_settings_rollback.sql


REM
psql -U postgres -d auth_db -f  20260303_seed_magic_link_email_type.sql


REM
psql -U postgres -d auth_db -f  20260303_seed_magic_link_email_type_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_add_api_key_scopes_columns.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_add_api_key_scopes_columns_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_add_app_bruteforce_settings.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_add_app_bruteforce_settings_rollback.sql
pause

REM
psql -U postgres -d auth_db -f  20260305_add_webhooks.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_add_webhooks_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_create_api_key_usages.sql

REM

psql -U postgres -d auth_db -f  20260305_create_api_key_usages_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_seed_api_key_expiring_soon_email_type.sql

REM
pause

REM
psql -U postgres -d auth_db -f  20260305_seed_api_key_expiring_soon_email_type_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_seed_security_email_types.sql

REM

REM
psql -U postgres -d auth_db -f  20260305_seed_security_email_types_rollback.sql


REM
psql -U postgres -d auth_db -f  20260306_add_oidc.sql


REM
psql -U postgres -d auth_db -f  20260306_add_oidc_rollback.sql


REM
psql -U postgres -d auth_db -f  20260309_seed_backup_email_verification_type.sql


REM
psql -U postgres -d auth_db -f  20260310_add_two_fa_previous_method.sql

REM

REM
psql -U postgres -d auth_db -f  20260310_add_two_fa_previous_method_rollback.sql

REM

REM
psql -U postgres -d auth_db -f  20260311_add_app_customization.sql

REM

REM
psql -U postgres -d auth_db -f  20260311_add_app_customization_rollback.sql



REM

REM
psql -U postgres -d auth_db -f  20260314_add_app_link_paths.sql

REM

REM
psql -U postgres -d auth_db -f  20260314_add_app_link_paths_rollback.sql

REM
psql -U postgres -d auth_db -f  20260317_add_settings_permissions_to_member.sql



REM
psql -U postgres -d auth_db -f  20260317_add_settings_permissions_to_member_rollback.sql



REM
psql -U postgres -d auth_db -f  20260808_add_fleet_vehicle_telemetry_tables.sql



REM
psql -U postgres -d auth_db -f  20260808_add_fleet_vehicle_telemetry_tables_rollback.sql



REM
psql -U postgres -d auth_db -f  20260808_add_maintenance_workorder_tables.sql

REM

echo finalização das Migração
pause