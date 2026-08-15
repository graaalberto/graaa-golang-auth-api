DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'maintenance_db') THEN
        CREATE DATABASE maintenance_db;
    END IF;
END $$;
