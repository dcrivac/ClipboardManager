# Lemon Squeezy Integration Guide for Clipso

## Overview

This guide covers the complete setup for integrating Lemon Squeezy payment processing into Clipso, including:
- Lemon Squeezy account setup
- Product configuration
- API integration for the macOS app
- Web checkout integration for the landing page
- License validation

## Step 1: Lemon Squeezy Account Setup

### 1.1 Create Account
1. Go to https://lemonsqueezy.com
2. Sign up for a new account
3. Complete business verification
4. Add your business details

### 1.2 Store Setup
1. Go to Settings → Stores
2. Create a new store (or use default)
3. Configure:
   - Store name: "Clipso"
   - Store URL: Your domain (e.g., clipso.app)
   - Currency: USD
   - Tax settings (if applicable)

## Step 2: Create Products

### Product 1: Lifetime Pro License
1. Go to Products → New Product
2. Configure:
   - **Name:** Clipso Pro - Lifetime License
   - **Description:** One-time payment for lifetime access to all Pro features
   - **Price:** $29.99 USD
   - **Type:** Single payment (one-time)
   - **Delivery:** License Key
3. Save and note the **Product ID** (e.g., `123456`)

### Product 2: Annual Subscription
1. Go to Products → New Product
2. Configure:
   - **Name:** Clipso Pro - Annual
   - **Description:** Annual subscription to Pro features
   - **Price:** $7.99 USD / year
   - **Type:** Subscription
   - **Billing period:** Yearly
   - **Trial:** 14 days (optional)
   - **Delivery:** License Key
3. Save and note the **Product ID** (e.g., `234567`)

### Product 3: Monthly Subscription (Optional)
1. Go to Products → New Product
2. Configure:
   - **Name:** Clipso Pro - Monthly
   - **Description:** Monthly subscription to Pro features
   - **Price:** $0.99 USD / month
   - **Type:** Subscription
   - **Billing period:** Monthly
   - **Trial:** 7 days (optional)
   - **Delivery:** License Key
3. Save and note the **Product ID** (e.g., `345678`)

## Step 3: Get API Credentials

### 3.1 API Key (for license validation)
1. Go to Settings → API
2. Click "Create API Key"
3. Name it "Clipso macOS App"
4. Copy the API key (starts with `lsk_...`)
5. **IMPORTANT:** Store securely - never commit to git!

### 3.2 Store ID
1. Go to Settings → Stores
2. Copy your Store ID (numeric, e.g., `12345`)

### 3.3 Product IDs
After creating products, note down:
```
LEMONSQUEEZY_STORE_ID=12345
LEMONSQUEEZY_LIFETIME_PRODUCT_ID=123456
LEMONSQUEEZY_ANNUAL_PRODUCT_ID=234567
LEMONSQUEEZY_MONTHLY_PRODUCT_ID=345678
LEMONSQUEEZY_API_KEY=lsk_xxxxxxxxxxxxxxxxxxxxxxxx
```

## Step 4: Configure Webhooks (Important!)

Webhooks notify your app about subscription events.

### 4.1 Create Webhook
1. Go to Settings → Webhooks
2. Click "Add webhook"
3. Configure:
   - **URL:** `https://yourdomain.com/api/lemonsqueezy/webhook`
   - **Signing secret:** Copy this! (starts with `whsec_...`)
   - **Events to listen for:**
     - `order_created` - New purchase
     - `subscription_created` - New subscription
     - `subscription_updated` - Subscription renewed
     - `subscription_cancelled` - User cancelled
     - `subscription_expired` - Subscription ended
     - `subscription_payment_success` - Payment succeeded
     - `subscription_payment_failed` - Payment failed
     - `license_key_created` - License generated

### 4.2 Test Webhook
1. Use ngrok or similar to expose local server
2. Update webhook URL temporarily
3. Make test purchase
4. Verify events are received

## Step 5: License Key Configuration

### 5.1 Enable License Keys for Products
1. Go to each product
2. Scroll to "License Keys" section
3. Enable license keys
4. Configure:
   - **Activation limit:** 2 devices (or unlimited for lifetime)
   - **Key format:** Auto-generated
   - **Expires:** Never (for lifetime), or follow subscription (for annual/monthly)

### 5.2 License Key Format
Lemon Squeezy generates keys like:
```
XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
```

You can customize the format in Settings → License Keys.

## Step 6: Test Mode

Before going live, test everything:

### 6.1 Enable Test Mode
1. Go to Settings → Test Mode
2. Toggle "Test mode" ON
3. All transactions will be simulated

### 6.2 Test Cards
Use Lemon Squeezy test cards:
- **Success:** 4242 4242 4242 4242
- **Decline:** 4000 0000 0000 0002
- **Requires authentication:** 4000 0025 0000 3155

### 6.3 Test Flow
1. Create test purchase from landing page
2. Verify checkout opens
3. Complete test payment
4. Check license key is generated
5. Activate license in macOS app
6. Verify Pro features unlock

## Step 7: Integration Points

### 7.1 Landing Page (HTML/JS)
- Use Lemon Squeezy.js for checkout overlay
- Product variant selection
- Custom data for license generation

### 7.2 macOS App (Swift)
- License activation UI
- API validation with Lemon Squeezy
- Keychain storage
- Pro feature gating

### 7.3 License Validation Flow
```
1. User purchases → Lemon Squeezy generates license key
2. License key sent via email
3. User enters key in app
4. App validates with Lemon Squeezy API
5. If valid, store in Keychain and enable Pro features
6. Re-validate every 7 days (optional, prevents abuse)
```

## Step 8: Go Live Checklist

- [ ] All products created with correct pricing
- [ ] API key generated and stored securely
- [ ] Webhooks configured and tested
- [ ] License keys enabled for all products
- [ ] Test mode purchases successful
- [ ] License activation works in app
- [ ] Pro features unlock correctly
- [ ] Subscription renewal tested
- [ ] Cancellation flow tested
- [ ] Refund flow tested
- [ ] Switch to Production mode
- [ ] Update all Product IDs to production IDs
- [ ] Test one real purchase (refund after)

## Configuration Summary

Store these values in your app configuration:

```swift
// LicenseManager.swift
private let storeID = "YOUR_STORE_ID"
private let lifetimeProductID = "YOUR_LIFETIME_PRODUCT_ID"
private let annualProductID = "YOUR_ANNUAL_PRODUCT_ID"
private let apiKey = "YOUR_API_KEY" // Keep secret!
```

```javascript
// script.js (landing page)
const LEMONSQUEEZY_STORE_ID = 'YOUR_STORE_ID';
const LIFETIME_PRODUCT_ID = 'YOUR_LIFETIME_PRODUCT_ID';
const ANNUAL_PRODUCT_ID = 'YOUR_ANNUAL_PRODUCT_ID';
```

## Important Security Notes

1. **Never expose API keys in frontend code**
   - API keys should only be in the macOS app (compiled)
   - Use environment variables or secure config

2. **Store credentials in Keychain (macOS)**
   - Never store in UserDefaults or plain files
   - Use macOS Keychain Services API

3. **Validate licenses server-side if possible**
   - For pure client apps, validation in-app is OK
   - For better security, validate via your backend

4. **Rate limit validation requests**
   - Don't validate on every app launch
   - Cache validation result for 7 days

## API Endpoints

### Validate License Key
```
POST https://api.lemonsqueezy.com/v1/licenses/validate
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "license_key": "XXXX-XXXX-XXXX-XXXX-...",
  "instance_id": "unique-device-id"
}
```

### Activate License
```
POST https://api.lemonsqueezy.com/v1/licenses/activate
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "license_key": "XXXX-XXXX-XXXX-XXXX-...",
  "instance_name": "John's MacBook Pro"
}
```

### Deactivate License
```
POST https://api.lemonsqueezy.com/v1/licenses/deactivate
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "license_key": "XXXX-XXXX-XXXX-XXXX-...",
  "instance_id": "unique-device-id"
}
```

## Support & Resources

- **Documentation:** https://docs.lemonsqueezy.com
- **API Reference:** https://docs.lemonsqueezy.com/api
- **SDK (JavaScript):** https://github.com/lmsqueezy/lemonsqueezy.js
- **Support:** support@lemonsqueezy.com
- **Discord:** https://discord.gg/lemonsqueezy

## Next Steps

1. ✅ Complete this setup guide
2. ✅ Update LicenseManager.swift with Lemon Squeezy API
3. ✅ Update landing page with Lemon Squeezy checkout
4. ✅ Test in sandbox mode
5. ✅ Go live!

---

**Happy selling! 🍋**
