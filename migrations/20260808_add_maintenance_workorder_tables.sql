-- Create Maintenance API tables for work orders, spare parts, and work order parts

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS work_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL,
    priority TEXT NOT NULL DEFAULT 'MEDIUM',
    status TEXT NOT NULL DEFAULT 'PENDING',
    description TEXT NOT NULL,
    total_cost NUMERIC(12,2) NOT NULL DEFAULT 0,
    tenant_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_work_orders_tenant_id ON work_orders (tenant_id);
CREATE INDEX IF NOT EXISTS idx_work_orders_vehicle_id ON work_orders (vehicle_id);
CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders (status);

CREATE TABLE IF NOT EXISTS spare_parts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    stock_code VARCHAR(64) NOT NULL UNIQUE,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(12,2) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS work_order_parts (
    work_order_id UUID NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
    part_id UUID NOT NULL REFERENCES spare_parts(id) ON DELETE RESTRICT,
    quantity_used INTEGER NOT NULL CHECK (quantity_used > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (work_order_id, part_id)
);

CREATE INDEX IF NOT EXISTS idx_work_order_parts_work_order_id ON work_order_parts (work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_parts_part_id ON work_order_parts (part_id);
