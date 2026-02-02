-- Insert lifetime license for Everydayhustlehub@gmail.com
-- Generated: 2026-02-02
-- License Key: CLIPSO-72C8-26A5-B3FE-6166

INSERT INTO licenses (
    license_key,
    email,
    transaction_id,
    product_id,
    price_id,
    license_type,
    status,
    device_limit,
    purchased_at,
    expires_at,
    custom_data
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
);

-- To apply this license, run:
-- psql -h localhost -U postgres -d clipso_licenses -f insert-friend-license.sql
