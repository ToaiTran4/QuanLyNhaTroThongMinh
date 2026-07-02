-- V1__init_schema.sql
-- Initial schema for QuanLyNhaTroThongMinh

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Owners table
CREATE TABLE owners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    cognito_sub VARCHAR(64) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admins table
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    cognito_sub VARCHAR(64) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tenant settings table (1:1 with owner)
CREATE TABLE tenant_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    min_notice_days_normal INTEGER NOT NULL DEFAULT 30 CHECK (min_notice_days_normal >= 30),
    min_notice_days_violation INTEGER NOT NULL DEFAULT 5 CHECK (min_notice_days_violation BETWEEN 3 AND 7),
    violation_threshold_cycles INTEGER NOT NULL DEFAULT 1 CHECK (violation_threshold_cycles >= 1),
    invoice_day_of_month INTEGER NOT NULL DEFAULT 1 CHECK (invoice_day_of_month BETWEEN 1 AND 28),
    verification_mode VARCHAR(20) NOT NULL DEFAULT 'require',
    verification_timeout_minutes INTEGER NOT NULL DEFAULT 60 CHECK (verification_timeout_minutes > 0),
    payment_mode VARCHAR(20) NOT NULL DEFAULT 'manual',
    overdue_threshold_days INTEGER NOT NULL DEFAULT 5 CHECK (overdue_threshold_days > 0),
    deposit_handling_option VARCHAR(30) NOT NULL DEFAULT 'offset_last_rent',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(owner_id)
);

-- Rooms table
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    room_code VARCHAR(20) NOT NULL,
    area_m2 NUMERIC(6,2),
    base_rent NUMERIC(14,2) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'trong',
    initial_electric_reading NUMERIC(10,2),
    initial_water_reading NUMERIC(10,2),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(owner_id, room_code)
);

-- Tenant profiles table
CREATE TABLE tenant_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    national_id VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(owner_id, national_id)
);

-- Contracts table
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    tenant_profile_id UUID NOT NULL REFERENCES tenant_profiles(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    deposit_amount NUMERIC(14,2) NOT NULL,
    deposit_months INTEGER NOT NULL DEFAULT 1,
    monthly_rent NUMERIC(14,2) NOT NULL,
    first_month_billing_option VARCHAR(20) NOT NULL,
    min_lease_days INTEGER,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    termination_type VARCHAR(20),
    debt_carry_flag BOOLEAN NOT NULL DEFAULT false,
    actual_end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (end_date IS NULL OR end_date > start_date)
);

-- Co-residents table
CREATE TABLE co_residents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    national_id VARCHAR(20),
    move_in_date DATE NOT NULL,
    move_out_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Renter accounts table
CREATE TABLE renter_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID UNIQUE NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    tenant_profile_id UUID NOT NULL REFERENCES tenant_profiles(id) ON DELETE CASCADE,
    cognito_sub VARCHAR(64) UNIQUE,
    activation_token_hash VARCHAR(255),
    activation_token_expires_at TIMESTAMPTZ,
    activation_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    access_mode VARCHAR(20) NOT NULL DEFAULT 'full',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Termination requests table
CREATE TABLE termination_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    requested_by VARCHAR(20) NOT NULL,
    requested_end_date DATE NOT NULL,
    notice_type VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'requested',
    acknowledged_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    last_reminder_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Utility rates table
CREATE TABLE utility_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    utility_type VARCHAR(20) NOT NULL,
    tier_order INTEGER NOT NULL,
    threshold_from NUMERIC(10,2) NOT NULL,
    threshold_to NUMERIC(10,2),
    unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
    effective_from TIMESTAMPTZ NOT NULL,
    effective_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Utility readings table
CREATE TABLE utility_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    submitted_by_contract_id UUID REFERENCES contracts(id) ON DELETE SET NULL,
    period_month DATE NOT NULL,
    utility_type VARCHAR(20) NOT NULL,
    image_s3_key VARCHAR(512),
    ocr_raw_value NUMERIC(10,2),
    submitted_value NUMERIC(10,2),
    previous_value NUMERIC(10,2) NOT NULL,
    is_baseline BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(50) NOT NULL,
    verified_by VARCHAR(20),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id, period_month, utility_type)
);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    period_month DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    rent_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    electric_amount NUMERIC(14,2),
    water_amount NUMERIC(14,2),
    other_fee_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    issued_at TIMESTAMPTZ,
    due_date DATE,
    paid_at TIMESTAMPTZ,
    replaced_by_invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(contract_id, period_month)
);

-- Invoice line items table
CREATE TABLE invoice_line_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    item_type VARCHAR(30) NOT NULL,
    description VARCHAR(255),
    amount NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    method VARCHAR(30) NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    momo_transaction_id VARCHAR(100),
    confirmed_by VARCHAR(20) NOT NULL,
    confirmed_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Deposit transactions table
CREATE TABLE deposit_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID UNIQUE NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    deposit_amount NUMERIC(14,2) NOT NULL,
    deductions_total NUMERIC(14,2) NOT NULL DEFAULT 0,
    adjustments_included NUMERIC(14,2) NOT NULL DEFAULT 0,
    remaining_debt NUMERIC(14,2) NOT NULL DEFAULT 0,
    refund_method VARCHAR(30),
    refund_status VARCHAR(20),
    settled_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoice adjustments table
CREATE TABLE invoice_adjustments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    original_invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    applied_invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    delta_amount NUMERIC(14,2) NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    applied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Repair requests table
CREATE TABLE repair_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'moi',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Repair request images table
CREATE TABLE repair_request_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_request_id UUID NOT NULL REFERENCES repair_requests(id) ON DELETE CASCADE,
    s3_key VARCHAR(512) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    sender_type VARCHAR(20) NOT NULL,
    message TEXT,
    image_s3_key VARCHAR(512),
    related_entity_type VARCHAR(50),
    related_entity_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
    recipient_type VARCHAR(20) NOT NULL,
    recipient_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    read_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES owners(id) ON DELETE SET NULL,
    actor_type VARCHAR(20) NOT NULL,
    actor_id UUID NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_rooms_owner_id ON rooms(owner_id);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_contracts_owner_id ON contracts(owner_id);
CREATE INDEX idx_contracts_room_id ON contracts(room_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_utility_readings_room_id ON utility_readings(room_id);
CREATE INDEX idx_utility_readings_period_month ON utility_readings(period_month);
CREATE INDEX idx_utility_readings_status ON utility_readings(status);
CREATE INDEX idx_invoices_owner_id ON invoices(owner_id);
CREATE INDEX idx_invoices_contract_id ON invoices(contract_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_paid_at ON invoices(paid_at);
CREATE INDEX idx_tenant_settings_owner_id ON tenant_settings(owner_id);

-- Enable Row Level Security (RLS)
ALTER TABLE owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE co_residents ENABLE ROW LEVEL SECURITY;
ALTER TABLE renter_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE termination_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE utility_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE utility_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_line_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE deposit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE repair_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE repair_request_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
