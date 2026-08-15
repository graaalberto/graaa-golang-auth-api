-- Create Fleet API tables for vehicles and telemetry

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plate VARCHAR(16) NOT NULL,
    chassis VARCHAR(64) NOT NULL UNIQUE,
    model VARCHAR(128) NOT NULL,
    year INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    tenant_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vehicles_tenant_id ON vehicles (tenant_id);

CREATE TABLE IF NOT EXISTS telemetry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed DOUBLE PRECISION NOT NULL,
    fuel_level DOUBLE PRECISION NOT NULL,
    odometer_km DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_telemetry_vehicle_id ON telemetry (vehicle_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_vehicle_timestamp ON telemetry (vehicle_id, timestamp DESC);
