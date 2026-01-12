# Lemon Squeezy Setup Guide for Clipso

This guide walks through setting up Lemon Squeezy for Clipso payments, replacing the previous Paddle integration.

## Overview

Lemon Squeezy handles:
- One-time lifetime purchases ($29.99)
- Annual recurring subscriptions ($7.99/year)
- License key generation and validation
- Customer management and webhooks
- No dependency on Apple Developer account

## Step 1: Create Lemon Squeezy Account

### 1.1 Sign Up
1. Go to [lemonsqueezy.com](https://www.lemonsqueezy.com)
2. Click **Sign Up**
3. Create account with email and password
4. Verify email address
5. Complete profile setup

### 1.2 Create a Store
1. After login, go to **Stores**
2. Click **Create Store**
3. Enter:
   - **Store Name**: `Clipso`
   - **Website**: `https://clipso.app` (or your domain)
   - **Currency**: USD (or your preferred)
4. Click **Create Store**
5. **Save your Store ID** - you'll need this

## Step 2: Create Products

### 2.1 Create Lifetime Purchase Product
1. In your store, go to **Products**
2. Click **Create Product**
3. Fill in:
   - **Name**: `Lifetime Pro`
   - **Description**: `Unlock all Pro features forever with a one-time payment`
   - **Price**: $29.99
   - **Type**: One-time Purchase
4. Go to **License Key Settings**:
   - Check **License keys enabled**
   - Validity period: Unlimited (or your preference)
5. Click **Create Product**
6. **Save the Product ID** - you'll need this

### 2.2 Create Annual Subscription Product
1. Click **Create Product** again
2. Fill in:
   - **Name**: `Annual Pro`
   - **Description**: `Unlock all Pro features. Renews every year.`
   - **Price**: $7.99
   - **Billing cycle**: Monthly × 12 (annual)
   - **Type**: Subscription
3. Go to **License Key Settings**:
   - Check **License keys enabled**
   - Validity period: Custom - match billing cycle
4. Click **Create Product**
5. **Save the Product ID** - you'll need this

### 2.3 Verify Product IDs
- Lifetime Product ID: Note format - you'll use this in code
- Annual Product ID: Note format - you'll use this in code

## Step 3: Set Up License Validation Webhook (Optional but Recommended)

This allows real-time license validation without API calls on every check.

### 3.1 Create License Validation Endpoint
For production, you'd set up a webhook endpoint at your backend to:
- Receive license validation requests
- Validate in Lemon Squeezy system
- Return validation response

### 3.2 Configure Webhook
1. Go to **Settings** → **Webhooks**
2. Click **Create webhook**
3. **Webhook URL**: Your endpoint that validates licenses
4. **Events**: Select `license_key.updated`
5. Click **Save**

For development/testing, you can skip this and use direct API validation.

## Step 4: Update Clipso Code

### 4.1 Add Store ID to LemonSqueezyManager
Edit `Clipso/Managers/LemonSqueezyManager.swift`:

```swift
private let storeId = "YOUR_LEMON_SQUEEZY_STORE_ID" // Replace
private let lifetimeProductId = "YOUR_LIFETIME_PRODUCT_ID" // Replace
private let annualProductId = "YOUR_ANNUAL_PRODUCT_ID" // Replace
```

Replace with your actual IDs from Lemon Squeezy.

### 4.2 Update Checkout URLs
The manager already constructs checkout URLs automatically:
```swift
func purchaseLifetime() {
    let checkoutURL = "https://\(storeId).lemonsqueezy.com/checkout/buy/\(lifetimeProductId)"
    if let url = URL(string: checkoutURL) {
        NSWorkspace.shared.open(url)
    }
}
```

This opens Lemon Squeezy's hosted checkout in the user's browser.

## Step 5: License Activation Flow

### 5.1 How It Works

1. **User purchases** via Lemon Squeezy checkout
2. **Lemon Squeezy sends** email with license key
3. **User opens Clipso** → Menu bar → **Activate License...**
4. **User enters** email + license key
5. **App validates** with Lemon Squeezy API
6. **App stores** license in Keychain
7. **Pro features unlock**

### 5.2 License Activation View
Users interact with `LicenseActivationView`:
- Enter email and license key
- Validate against Lemon Squeezy
- Store in secure Keychain
- Unlock Pro features

### 5.3 Direct Purchase
Users can also click:
- **Menu bar** → **Upgrade to Pro...** → Select plan
- **Settings** → **Upgrade to Pro** button
- Both open Lemon Squeezy checkout in browser

## Step 6: Testing

### Test Flow
1. **Build and run** Clipso
2. **Click** "Upgrade to Pro..." from menu bar
3. **Verify** it opens Lemon Squeezy checkout
4. **Create test purchase** using Lemon Squeezy sandbox (if available)
5. **Get license key** from test email
6. **In Clipso** → **Activate License...**
7. **Enter** email and license key
8. **Verify** Pro status appears in Settings
9. **Verify** Pro features are accessible

### Testing Without Purchase
To test without making a real purchase:
1. Create a test/staging Lemon Squeezy account
2. Use the sandbox checkout if available
3. Or manually create license keys in Lemon Squeezy dashboard for testing

## Step 7: Production Setup

### 7.1 Add Banking Information
1. Go to **Settings** → **Payouts**
2. Add bank account details
3. Set payout frequency
4. Verify banking info

### 7.2 Create Support Resources
- Add refund policy
- Create license key documentation
- Set up customer support email

### 7.3 Deploy App
1. Replace test Store/Product IDs with production IDs
2. Build and notarize Mac app
3. Distribute via your website

## Configuration Checklist

- [ ] Lemon Squeezy account created
- [ ] Store created (have Store ID)
- [ ] Lifetime product created (have Product ID)
- [ ] Annual product created (have Product ID)
- [ ] License keys enabled on both products
- [ ] Store ID added to LemonSqueezyManager.swift
- [ ] Lifetime Product ID added to code
- [ ] Annual Product ID added to code
- [ ] Test checkout flow works
- [ ] Test license activation works
- [ ] Banking info added (for production)

## File Reference

| File | Purpose |
|------|---------|
| `Managers/LemonSqueezyManager.swift` | License management via Lemon Squeezy |
| `Views/LicenseActivationView.swift` | License key entry UI |
| `ClipsoApp.swift` | Purchase menu integration |
| `Views/SettingsView.swift` | License status display |
| `LEMON_SQUEEZY_SETUP_GUIDE.md` | This guide |

## Advantages of Lemon Squeezy

✅ **No Apple Developer Account** - Direct payment processing
✅ **Fast Approval** - Typically 24-48 hours
✅ **License Keys** - Built-in license key generation
✅ **Lower Fees** - Competitive pricing
✅ **Easy Setup** - Simple dashboard
✅ **Webhook Support** - Real-time event notifications
✅ **License Validation API** - Check licenses server-side or client-side
✅ **Indie Friendly** - Designed for solo developers

## Monetization Model

- **Free Tier**: 250 items, 30-day retention, keyword search
- **Lifetime**: $29.99 (one-time, never expires)
- **Annual**: $7.99/year (recurring, auto-renews)

## Troubleshooting

### Issue: Checkout URL not opening
**Check:**
- Store ID is correct (matches Lemon Squeezy)
- Product ID is correct
- No typos in URLs

### Issue: License validation fails
**Check:**
- Email matches email used at purchase
- License key is exact (case-sensitive)
- License hasn't been deactivated

### Issue: License keys not generating
**Check:**
- Product has license keys enabled in settings
- License key settings are configured
- Product is active/published

## Support

- **Lemon Squeezy Docs**: https://docs.lemonsqueezy.com
- **Lemon Squeezy Support**: support@lemonsqueezy.com
- **License Key API**: https://docs.lemonsqueezy.com/api/license-keys

## Next Steps

1. Complete Steps 1-2 above (Lemon Squeezy setup)
2. Replace placeholder IDs in code
3. Test checkout and license activation
4. Deploy!
