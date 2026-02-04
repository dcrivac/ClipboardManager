/**
 * ONE-TIME DATABASE SETUP ENDPOINT
 *
 * Add this code to server.js BEFORE the app.listen() line.
 * After setup is complete, remove this code for security.
 *
 * Usage: GET /setup-database?secret=clipso-setup-2024
 */

// Copy this entire block and paste it into server.js before app.listen()

app.get('/setup-database', async (req, res) => {
    // Security: require secret key
    const secretKey = process.env.SETUP_SECRET || 'clipso-setup-2024';
    if (req.query.secret !== secretKey) {
        return res.status(403).json({ error: 'Unauthorized - secret key required' });
    }

    console.log('🔧 Starting database setup...');

    try {
        const client = await pool.connect();

        // Run the complete schema
        await client.query(`
-- Licenses table
CREATE TABLE IF NOT EXISTS licenses (
    id SERIAL PRIMARY KEY,
    license_key VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    price_id VARCHAR(255) NOT NULL,
    license_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    device_limit INTEGER NOT NULL DEFAULT 3,
    purchased_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP,
    last_validated TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paddle_customer_id VARCHAR(255),
    paddle_subscription_id VARCHAR(255),
    custom_data JSONB
);

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    license_id INTEGER NOT NULL REFERENCES licenses(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    device_model VARCHAR(255),
    os_version VARCHAR(255),
    app_version VARCHAR(255),
    activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deactivated_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    ip_address VARCHAR(45),
    UNIQUE(license_id, device_id)
);

-- Webhook events table
CREATE TABLE IF NOT EXISTS webhook_events (
    id SERIAL PRIMARY KEY,
    event_id VARCHAR(255) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    transaction_id VARCHAR(255),
    customer_id VARCHAR(255),
    subscription_id VARCHAR(255),
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP,
    error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Validation logs table
CREATE TABLE IF NOT EXISTS validation_logs (
    id SERIAL PRIMARY KEY,
    license_key VARCHAR(255) NOT NULL,
    device_id VARCHAR(255),
    validation_result VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_licenses_license_key ON licenses(license_key);
CREATE INDEX IF NOT EXISTS idx_licenses_email ON licenses(email);
CREATE INDEX IF NOT EXISTS idx_licenses_transaction_id ON licenses(transaction_id);
CREATE INDEX IF NOT EXISTS idx_licenses_status ON licenses(status);
CREATE INDEX IF NOT EXISTS idx_devices_license_id ON devices(license_id);
CREATE INDEX IF NOT EXISTS idx_devices_device_id ON devices(device_id);
CREATE INDEX IF NOT EXISTS idx_devices_is_active ON devices(is_active);
CREATE INDEX IF NOT EXISTS idx_webhook_events_event_id ON webhook_events(event_id);
CREATE INDEX IF NOT EXISTS idx_webhook_events_event_type ON webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_webhook_events_transaction_id ON webhook_events(transaction_id);
CREATE INDEX IF NOT EXISTS idx_webhook_events_processed ON webhook_events(processed);
CREATE INDEX IF NOT EXISTS idx_validation_logs_license_key ON validation_logs(license_key);
CREATE INDEX IF NOT EXISTS idx_validation_logs_created_at ON validation_logs(created_at);

-- Functions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
DROP TRIGGER IF EXISTS update_licenses_updated_at ON licenses;
CREATE TRIGGER update_licenses_updated_at
    BEFORE UPDATE ON licenses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Views
CREATE OR REPLACE VIEW active_licenses_summary AS
SELECT
    l.id,
    l.license_key,
    l.email,
    l.license_type,
    l.status,
    l.device_limit,
    COUNT(d.id) FILTER (WHERE d.is_active = TRUE) as active_devices,
    l.purchased_at,
    l.expires_at,
    l.last_validated
FROM licenses l
LEFT JOIN devices d ON l.id = d.license_id
WHERE l.status = 'active'
GROUP BY l.id;

CREATE OR REPLACE VIEW devices_summary AS
SELECT
    d.id,
    d.device_id,
    d.device_name,
    l.license_key,
    l.email,
    l.license_type,
    d.activated_at,
    d.last_seen,
    d.is_active
FROM devices d
JOIN licenses l ON d.license_id = l.id
WHERE d.is_active = TRUE;
        `);

        console.log('✅ Tables, indexes, and views created');

        // Insert friend's license
        await client.query(`
INSERT INTO licenses (
    license_key, email, transaction_id, product_id, price_id,
    license_type, status, device_limit, purchased_at, expires_at, custom_data
) VALUES (
    'CLIPSO-72C8-26A5-B3FE-6166',
    'Everydayhustlehub@gmail.com',
    'manual_1770022038899_409794acd8db2366',
    'prod_clipso_lifetime',
    'manual',
    'lifetime',
    'active',
    3,
    '2026-02-02T08:47:18.900Z',
    NULL,
    '{"source": "manual", "generated_by": "admin"}'::jsonb
)
ON CONFLICT (license_key) DO NOTHING;
        `);

        console.log('✅ Friend license added');

        // Verify setup
        const licenseCheck = await client.query(
            "SELECT * FROM licenses WHERE email = 'Everydayhustlehub@gmail.com'"
        );

        client.release();

        console.log('🎉 Database setup complete!');

        res.json({
            success: true,
            message: '🎉 Database initialized successfully!',
            tables_created: ['licenses', 'devices', 'webhook_events', 'validation_logs'],
            indexes_created: 13,
            views_created: ['active_licenses_summary', 'devices_summary'],
            friend_license: {
                added: true,
                email: 'Everydayhustlehub@gmail.com',
                license_key: 'CLIPSO-72C8-26A5-B3FE-6166',
                type: 'lifetime',
                found_in_db: licenseCheck.rows.length > 0
            },
            next_steps: [
                '1. Test activation: curl -X POST https://your-url/api/licenses/activate ...',
                '2. Remove this /setup-database endpoint from server.js',
                '3. Redeploy to production',
                '4. Configure Paddle webhook',
                '5. Start selling!'
            ]
        });

    } catch (error) {
        console.error('❌ Setup error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            hint: 'Check that DATABASE_URL is set correctly in environment variables'
        });
    }
});
