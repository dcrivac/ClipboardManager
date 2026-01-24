# Paddle Billing Setup for Clipso

Your Paddle Billing account is approved! Here's how to complete the integration.

## 🎯 Quick Setup Checklist

- [ ] Create product "Clipso Pro" in Paddle
- [ ] Add Lifetime price ($29.99 one-time)
- [ ] Add Annual price ($7.99/year)
- [ ] Copy Price IDs
- [ ] Get Client-side token
- [ ] Update website/script.js
- [ ] Update Managers/LicenseManager.swift
- [ ] Test in Sandbox
- [ ] Switch to Production

## Step-by-Step Guide

### 1. Create Products in Paddle

**Go to: Dashboard → Catalog → Products → + Product**

#### Product: Clipso Pro

```
Product Name: Clipso Pro
Description: AI-powered clipboard manager with semantic search,
             context detection, and unlimited clipboard history
Tax Category: Standard (SaaS)
Product Image: https://raw.githubusercontent.com/dcrivac/Clipso/main/assets/logo-512.png
```

Save the product.

### 2. Add Prices

After creating the product, click into it and add prices:

#### Price 1: Lifetime License

```
Price Name: Lifetime License
Description: One-time payment for lifetime access to all Pro features
Billing Period: One-time
Unit Price: $29.99 USD
```

**✅ Copy the Price ID** (example: `pri_01h8abc123def456`)

#### Price 2: Annual Subscription

```
Price Name: Annual Subscription
Description: Annual subscription with all Pro features
Billing Period: Year
Unit Price: $7.99 USD
Trial Period: 14 days (optional)
```

**✅ Copy the Price ID** (example: `pri_01h8xyz789ghi012`)

### 3. Get Your Credentials

**Go to: Developer Tools → Authentication**

You'll see two environments:

#### Sandbox (for testing)
- **Client-side token**: `test_abc123...`
- Use this while developing and testing

#### Live (for production)
- **Client-side token**: `live_xyz789...`
- Use this when you're ready to accept real payments

**✅ Copy both tokens** and store them securely.

### 4. Update website/script.js

Open `website/script.js` and update these lines:

```javascript
// Paddle Configuration
const PADDLE_VENDOR_ID = 'test_abc123...'; // Your SANDBOX client-side token
const PADDLE_ENVIRONMENT = 'sandbox'; // Use 'sandbox' for testing
const LIFETIME_PRICE_ID = 'pri_01h8abc123def456'; // Your Lifetime Price ID
const ANNUAL_PRICE_ID = 'pri_01h8xyz789ghi012'; // Your Annual Price ID
```

**Important:** Use your **Sandbox** token and Sandbox price IDs for testing!

### 5. Update Managers/LicenseManager.swift

Open `Managers/LicenseManager.swift` and update these lines:

```swift
// Paddle Configuration
private let vendorID = "test_abc123..." // Your SANDBOX client-side token
private let lifetimePriceID = "pri_01h8abc123def456" // Lifetime Price ID
private let annualPriceID = "pri_01h8xyz789ghi012" // Annual Price ID
private let apiKey = "YOUR_API_KEY" // Get from Developer Tools → API Keys
private let useSandbox = true // Keep true for testing
```

**Note:** For the `apiKey`, you need to create an API key in **Developer Tools → API Keys** with these scopes:
- `transaction:read`
- `customer:read`

### 6. Test in Sandbox

#### Update your website script to use Paddle Billing SDK:

The script should already be set up, but verify these are in `website/index.html`:

```html
<!-- Paddle Billing SDK -->
<script src="https://cdn.paddle.com/paddle/v2/paddle.js"></script>
```

#### Test the checkout flow:

1. Open your website locally or on GitHub Pages
2. Click "Get Lifetime Pro" or "Get Annual Pro"
3. Use Paddle's test card:
   - **Card**: 4242 4242 4242 4242
   - **Expiry**: Any future date (e.g., 12/26)
   - **CVC**: Any 3 digits (e.g., 123)
4. Complete the checkout
5. Verify you receive a confirmation

#### Check transaction in Paddle:

1. Go to **Transactions** in Paddle Dashboard
2. You should see your test transaction
3. Click into it to see the details

### 7. Set Up Webhooks (Optional but Recommended)

Webhooks allow automatic license activation. See `guides/PADDLE_CUSTOM_DATA.md` for details.

**Quick setup:**

1. Go to **Developer Tools → Notifications → + Notification**
2. URL: Your webhook endpoint (e.g., `https://yourdomain.com/api/paddle-webhook`)
3. Select events:
   - ✅ `transaction.completed`
   - ✅ `subscription.created`
   - ✅ `subscription.cancelled`
4. Copy the **Notification Secret** for verification

### 8. Switch to Production

When ready to accept real payments:

#### Update website/script.js:

```javascript
const PADDLE_VENDOR_ID = 'live_xyz789...'; // Your LIVE client-side token
const PADDLE_ENVIRONMENT = 'production'; // Switch to production
// Use production Price IDs (create same products in Production)
```

#### Update Managers/LicenseManager.swift:

```swift
private let vendorID = "live_xyz789..." // Your LIVE client-side token
private let useSandbox = false // Switch to production
// Use production Price IDs
```

**Important:** You need to create the same products in the **Live** environment to get production Price IDs!

## Paddle Billing vs Classic

You're using **Paddle Billing** (the newer version). Key differences:

| Feature | Paddle Classic | Paddle Billing |
|---------|---------------|----------------|
| **Credentials** | Vendor ID (numbers) | Client-side token (`test_` / `live_`) |
| **Price IDs** | Product IDs (numbers) | Price IDs (`pri_01h...`) |
| **SDK** | Paddle.js v1 | Paddle.js v2 |
| **Checkout** | `Paddle.Checkout.open()` | Same, but different params |
| **Webhooks** | Alerts | Notifications |

Your current code is already set up for Paddle Billing! ✅

## Testing Checklist

- [ ] Products created in Sandbox
- [ ] Price IDs copied correctly
- [ ] Sandbox token added to code
- [ ] Website opens checkout when clicking "Get Pro"
- [ ] Test card completes purchase
- [ ] Transaction appears in Paddle Dashboard
- [ ] Custom data appears in transaction (if using)
- [ ] Webhook receives notification (if set up)

## Production Checklist

- [ ] Products created in Live environment
- [ ] Live Price IDs copied
- [ ] Live token added to code
- [ ] Website deployed with production config
- [ ] Test one real purchase (refund it after)
- [ ] Verify real transaction in Dashboard
- [ ] Monitor for any errors

## Common Issues

### "Paddle is not defined"
**Solution:** Make sure Paddle SDK is loading:
```html
<script src="https://cdn.paddle.com/paddle/v2/paddle.js"></script>
```

### Checkout doesn't open
**Solution:** Check browser console for errors. Verify:
- Price IDs are correct
- Client-side token is valid
- Environment matches (sandbox vs production)

### "Invalid price"
**Solution:** You're using Sandbox price IDs in Production (or vice versa). Each environment has separate Price IDs.

### Transaction not appearing
**Solution:** Check you're looking in the correct environment (Sandbox vs Live)

## Next Steps

1. **Create products** in Paddle Sandbox (Step 1-2)
2. **Get credentials** (Step 3)
3. **Update code** (Step 4-5)
4. **Test** with test card (Step 6)
5. **Set up webhooks** for auto-activation (Step 7)
6. **Go live** when ready (Step 8)

## Resources

- **Paddle Billing Docs**: https://developer.paddle.com/
- **Checkout Guide**: https://developer.paddle.com/build/checkout/build-overlay-checkout
- **Price IDs**: https://developer.paddle.com/build/products/create-products-prices
- **Custom Data**: See `guides/PADDLE_CUSTOM_DATA.md`
- **Webhooks**: https://developer.paddle.com/webhooks/overview

## Support

Need help? Open an issue: https://github.com/dcrivac/Clipso/issues

---

**Status:** ✅ Paddle Billing account approved and ready!

**Current Progress:**
- ✅ Code is set up for Paddle Billing
- ✅ PNG logos created for product images
- ⏳ Need to create products and get Price IDs
- ⏳ Need to update code with real credentials

**What's Next:** Follow Steps 1-6 above to complete the setup!
