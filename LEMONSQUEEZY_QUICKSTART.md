# Lemon Squeezy Quick Start Guide

## What Changed?

Your Clipso app has been updated to use **Lemon Squeezy** instead of Paddle for payment processing. Here's what was modified:

### Files Updated:
1. ✅ `Clipso/Managers/LicenseManager.swift` - Updated to Lemon Squeezy API
2. ✅ `script.js` - Updated checkout to Lemon Squeezy
3. ✅ `index.html` - Replaced Paddle.js with Lemon Squeezy script
4. ✅ `.env.template` - Configuration template for your credentials
5. ✅ `.gitignore` - Added to protect secrets
6. ✅ `LEMONSQUEEZY_SETUP.md` - Full integration guide

## Quick Setup (5 Steps)

### Step 1: Create Lemon Squeezy Account
1. Go to https://lemonsqueezy.com
2. Sign up and verify your account
3. Complete business details

### Step 2: Create Products
Create these 2-3 products in Lemon Squeezy:

**Product 1: Lifetime Pro**
- Name: Clipso Pro - Lifetime License
- Price: $29.99 (one-time)
- Type: Single payment
- Enable License Keys: Yes

**Product 2: Annual Pro**
- Name: Clipso Pro - Annual
- Price: $7.99/year
- Type: Subscription (Yearly)
- Enable License Keys: Yes

**Product 3: Monthly Pro (Optional)**
- Name: Clipso Pro - Monthly
- Price: $0.99/month
- Type: Subscription (Monthly)
- Enable License Keys: Yes

### Step 3: Get Your Credentials
Go to Settings and copy these values:

```
Store ID: _______________  (Settings → Stores)
API Key:  _______________  (Settings → API → Create API Key)

Lifetime Product ID: _______________  (Products → Lifetime → Edit)
Annual Product ID:   _______________  (Products → Annual → Edit)
```

### Step 4: Update Your Code

#### A. Update LicenseManager.swift
Open `Clipso/Managers/LicenseManager.swift` and replace:

```swift
private let storeID = "YOUR_LEMONSQUEEZY_STORE_ID"
private let lifetimeProductID = "YOUR_LIFETIME_PRODUCT_ID"
private let annualProductID = "YOUR_ANNUAL_PRODUCT_ID"
private let apiKey = "YOUR_LEMONSQUEEZY_API_KEY"
```

With your actual values from Step 3.

#### B. Update script.js
Open `script.js` (lines 18-20) and replace:

```javascript
const LEMONSQUEEZY_STORE_ID = 'YOUR_STORE_ID';
const LIFETIME_PRODUCT_ID = 'YOUR_LIFETIME_PRODUCT_ID';
const ANNUAL_PRODUCT_ID = 'YOUR_ANNUAL_PRODUCT_ID';
```

With your actual values from Step 3.

### Step 5: Test Everything

#### Test in Sandbox Mode:
1. Enable Test Mode in Lemon Squeezy (Settings → Test Mode)
2. Build and run your Xcode project
3. Open the landing page (index.html)
4. Click "Get Lifetime Pro"
5. Use test card: 4242 4242 4242 4242
6. Complete test purchase
7. Check email for license key
8. Activate license in macOS app
9. Verify Pro features unlock

## File Reference

### Where Each Value Goes:

| Value | LicenseManager.swift | script.js | Keep Secret? |
|-------|---------------------|-----------|--------------|
| Store ID | ✅ | ✅ | No |
| Lifetime Product ID | ✅ | ✅ | No |
| Annual Product ID | ✅ | ✅ | No |
| API Key | ✅ | ❌ | **YES!** |

**Important:** The API key should ONLY be in `LicenseManager.swift` (compiled into the app). Never put it in JavaScript files!

## Testing Checklist

Before going live, test these scenarios:

### Free User:
- [ ] App runs without license
- [ ] Semantic search is locked (Pro only)
- [ ] Max 250 items enforced
- [ ] Max 30 days retention enforced
- [ ] "Upgrade to Pro" button opens checkout

### Checkout Flow:
- [ ] Lifetime checkout opens in overlay
- [ ] Annual checkout opens in overlay
- [ ] Test purchase completes successfully
- [ ] License key received via email
- [ ] License key format is valid

### License Activation:
- [ ] Can open activation window
- [ ] Can enter license key
- [ ] Invalid key shows error
- [ ] Valid key activates successfully
- [ ] Pro features unlock immediately
- [ ] License persists after app restart

### Pro User:
- [ ] All search modes available
- [ ] No item limit
- [ ] No retention limit
- [ ] Settings show "Pro License Active"
- [ ] Can deactivate license

## Going Live

Once testing is complete:

1. **Switch to Production:**
   - Disable Test Mode in Lemon Squeezy
   - Get production Product IDs
   - Update both files with production IDs

2. **Test One Real Purchase:**
   - Make a real purchase (you can refund after)
   - Verify everything works end-to-end

3. **Launch! 🚀**

## Troubleshooting

### Checkout doesn't open
- Check Store ID and Product IDs are correct
- Verify Lemon Squeezy script loaded (check browser console)
- Make sure products are published (not draft)

### License validation fails
- Verify API key is correct and active
- Check license key format
- Ensure product has license keys enabled
- Check API rate limits

### Pro features don't unlock
- Verify license saved to Keychain
- Check `isProUser` state in LicenseManager
- Restart app after activation
- Check console logs for errors

## Support

Need help? Check these resources:

- **Full Guide:** `LEMONSQUEEZY_SETUP.md`
- **Lemon Squeezy Docs:** https://docs.lemonsqueezy.com
- **API Reference:** https://docs.lemonsqueezy.com/api
- **Discord:** https://discord.gg/lemonsqueezy

## Security Reminder

**Never commit these to git:**
- `.env.local` (your actual credentials)
- Any file with real API keys
- Test license keys

**Already set up in .gitignore** ✅

---

## Quick Commands

Build and test:
```bash
# Open Xcode project
open Clipso.xcodeproj

# Build and run
⌘R in Xcode

# Test landing page
open index.html
```

---

**You're all set! 🍋**

Questions? Check `LEMONSQUEEZY_SETUP.md` for detailed documentation.
