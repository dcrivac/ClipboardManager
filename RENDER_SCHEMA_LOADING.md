# Load Database Schema on Render - Alternative Methods

If you don't see the "Shell" tab in Render, use one of these methods:

---

## Method 1: External Connection URL (Easiest)

### Step 1: Get Connection String

1. In Render, click your PostgreSQL database
2. Scroll down to **"Connections"** section
3. Find **"External Database URL"**
4. Click **"Show"** to reveal the connection string
5. Copy it (looks like: `postgres://user:pass@host/db`)

### Step 2: Connect from Your Computer

**If you have `psql` installed:**

```bash
# Load schema directly
psql "your-external-database-url-here" < backend/schema-fixed.sql
```

**If you don't have `psql`:**

Download it:
- **Mac:** `brew install postgresql`
- **Ubuntu/Linux:** `sudo apt install postgresql-client`
- **Windows:** Download from [postgresql.org/download/windows](https://www.postgresql.org/download/windows/)

Then run the command above.

---

## Method 2: Via Your Deployed Backend (Recommended)

Create a one-time setup endpoint in your backend.

### Step 1: Add Temporary Setup Endpoint

Add this to your backend code temporarily:

```javascript
// Add this BEFORE the line: app.listen(PORT, () => {

/**
 * ONE-TIME SETUP ENDPOINT
 * Remove after database is initialized!
 */
app.get('/setup-database', async (req, res) => {
    // Security: only allow in development or with secret key
    const secretKey = process.env.SETUP_SECRET || 'clipso-setup-2024';
    if (req.query.secret !== secretKey) {
        return res.status(403).json({ error: 'Unauthorized' });
    }

    try {
        const client = await pool.connect();

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

-- Insert your friend's license
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

        client.release();

        res.json({
            success: true,
            message: 'Database initialized successfully!',
            tables_created: ['licenses', 'devices', 'webhook_events', 'validation_logs'],
            friend_license_added: 'CLIPSO-72C8-26A5-B3FE-6166'
        });

    } catch (error) {
        console.error('Setup error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});
```

### Step 2: Deploy Updated Backend

Push changes to GitHub:

```bash
git add backend/server.js
git commit -m "Add temporary database setup endpoint"
git push
```

Render will automatically redeploy.

### Step 3: Call the Setup Endpoint

Once deployed, visit in your browser:

```
https://your-render-url.onrender.com/setup-database?secret=clipso-setup-2024
```

You should see:
```json
{
  "success": true,
  "message": "Database initialized successfully!",
  "tables_created": ["licenses", "devices", "webhook_events", "validation_logs"],
  "friend_license_added": "CLIPSO-72C8-26A5-B3FE-6166"
}
```

### Step 4: Remove the Setup Endpoint

**IMPORTANT:** Delete the setup endpoint code after setup is complete for security!

```bash
# Remove the setup endpoint code from server.js
git add backend/server.js
git commit -m "Remove setup endpoint"
git push
```

---

## Method 3: Using a Database Client Tool

### Option A: TablePlus (Mac/Windows)

1. Download [TablePlus](https://tableplus.com/) (free)
2. Create new connection → PostgreSQL
3. Paste connection details from Render:
   - Host, Port, User, Password, Database
4. Connect
5. Click "SQL" → Paste `backend/schema-fixed.sql`
6. Run query

### Option B: pgAdmin (Free, Cross-platform)

1. Download [pgAdmin](https://www.pgadmin.org/download/)
2. Create new server connection
3. Use connection details from Render
4. Right-click database → "Query Tool"
5. Paste `backend/schema-fixed.sql`
6. Execute

### Option C: DBeaver (Free, Cross-platform)

1. Download [DBeaver](https://dbeaver.io/download/)
2. New Connection → PostgreSQL
3. Enter Render connection details
4. SQL Editor → Paste schema
5. Execute

---

## Method 4: Use Render's Info Tab

Sometimes Render has a "Query" or "SQL Editor" tab:

1. Click your PostgreSQL database
2. Look for tabs: **Info**, **Metrics**, **Connect**, **Settings**
3. Check if there's a **"Query"** or **"SQL Editor"** option
4. If found, paste `backend/schema-fixed.sql` there

---

## Verify Schema is Loaded

After using any method above, verify:

```bash
curl https://your-render-url.onrender.com/health
```

Should return:
```json
{"status":"ok","timestamp":"..."}
```

Test license activation:
```bash
curl -X POST https://your-render-url.onrender.com/api/licenses/activate \
  -H "Content-Type: application/json" \
  -d '{"license_key":"CLIPSO-72C8-26A5-B3FE-6166","device_id":"test1","device_name":"Test","device_model":"Mac","os_version":"14","app_version":"1.0.3"}'
```

Should return:
```json
{"success":true,...}
```

---

## Quick Recommendation

**Use Method 2** (Setup endpoint) - it's the easiest and doesn't require installing anything!

1. Add the setup endpoint code to `backend/server.js`
2. Let Render redeploy
3. Visit: `https://your-url.onrender.com/setup-database?secret=clipso-setup-2024`
4. Remove the endpoint code
5. Done!

---

## Need Help?

If you get stuck, tell me:
1. What tabs DO you see in Render for your database?
2. Do you have `psql` installed on your computer?
3. Which method would you prefer to use?
