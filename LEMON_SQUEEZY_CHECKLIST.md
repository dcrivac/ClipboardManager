# Lemon Squeezy Implementation Checklist for Clipso

Step-by-step checklist for setting up Lemon Squeezy payments. Estimated time: 30 minutes.

---

## Section 1: Lemon Squeezy Account Setup (15 min)

### Prerequisites
- [ ] Email address ready for account creation
- [ ] Website or domain (can be placeholder like clipso.app)

### Steps

- [ ] **1.1 Create Account**
  - [ ] Go to [lemonsqueezy.com](https://www.lemonsqueezy.com)
  - [ ] Click **Sign Up** in top right
  - [ ] Enter email and create password
  - [ ] Verify email (check inbox + spam)
  - [ ] Log in to dashboard

- [ ] **1.2 Create Store**
  - [ ] Click **Stores** in sidebar
  - [ ] Click **Create Store** button
  - [ ] Fill in:
    - Store Name: `Clipso`
    - Website: `https://clipso.app` (placeholder OK)
    - Currency: USD (or your preference)
  - [ ] Click **Create Store**
  - [ ] **SAVE YOUR STORE ID** - copy and keep it safe
    - Format: numbers like `12345`
    - You'll need this in the code

- [ ] **1.3 Navigate to Products**
  - [ ] In your store, click **Products** in sidebar
  - [ ] You should see empty product list

---

## Section 2: Create Products (15 min)

### Product 1: Lifetime Purchase

- [ ] **2.1 Create Lifetime Product**
  - [ ] Click **Create Product** button
  - [ ] Fill in:
    - **Name**: `Lifetime Pro`
    - **Description**: `Unlock all Pro features forever with a one-time payment`
    - **Price**: `29.99`
    - **Type**: Select **One-time Purchase**
  - [ ] Scroll down to **License Key Settings**
  - [ ] Check ✓ **License keys enabled**
  - [ ] Set **Validity period**: Unlimited
  - [ ] Click **Create Product**

- [ ] **2.2 Get Lifetime Product ID**
  - [ ] After creation, click on the Lifetime product
  - [ ] Look for **Product ID** (usually in URL bar or product details)
  - [ ] **SAVE THIS ID** - format like `123456`
  - [ ] Example: `com.clipso.lifetime` or just `123456`

### Product 2: Annual Subscription

- [ ] **2.3 Create Annual Product**
  - [ ] Click **Create Product** again
  - [ ] Fill in:
    - **Name**: `Annual Pro`
    - **Description**: `Unlock all Pro features. Renews every year.`
    - **Price**: `7.99`
    - **Billing cycle**: Select **Monthly** then change quantity to **12** (annual)
    - **Type**: Select **Subscription**
  - [ ] Scroll to **License Key Settings**
  - [ ] Check ✓ **License keys enabled**
  - [ ] Set **Validity period**: Match billing cycle (or 1 year)
  - [ ] Click **Create Product**

- [ ] **2.4 Get Annual Product ID**
  - [ ] After creation, click on Annual product
  - [ ] **SAVE THIS ID** - format like `654321`
  - [ ] Example: `com.clipso.annual` or just `654321`

### Verification

- [ ] **2.5 Verify Both Products**
  - [ ] Go to **Products** list
  - [ ] See both products listed:
    - Lifetime Pro - $29.99
    - Annual Pro - $7.99/month × 12
  - [ ] License keys enabled on both

---

## Section 3: Update Code (10 min)

### Step 3.1: Update LemonSqueezyManager

- [ ] Open `Clipso/Managers/LemonSqueezyManager.swift`
- [ ] Find line 23-24:
  ```swift
  private let storeId = "YOUR_LEMON_SQUEEZY_STORE_ID"
  ```
- [ ] Replace with your actual Store ID:
  ```swift
  private let storeId = "12345"  // Your actual Store ID
  ```

- [ ] Find line 25-26:
  ```swift
  private let lifetimeProductId = "YOUR_LIFETIME_PRODUCT_ID"
  ```
- [ ] Replace with your Lifetime Product ID:
  ```swift
  private let lifetimeProductId = "123456"  // Your actual Lifetime ID
  ```

- [ ] Find line 27-28:
  ```swift
  private let annualProductId = "YOUR_ANNUAL_PRODUCT_ID"
  ```
- [ ] Replace with your Annual Product ID:
  ```swift
  private let annualProductId = "654321"  // Your actual Annual ID
  ```

- [ ] **Save file** (Cmd+S)

### Step 3.2: Verify Setup

- [ ] In Xcode, select **Clipso** target
- [ ] Click **Build** (Cmd+B)
- [ ] No build errors should occur
- [ ] If errors, verify product IDs are correct

---

## Section 4: Test the Integration (10 min)

### Prerequisites
- [ ] Code updates completed
- [ ] All IDs entered correctly
- [ ] Project builds successfully

### Test Flow

- [ ] **4.1 Build and Run**
  - [ ] In Xcode, press **Play** (⌘+R)
  - [ ] App should launch with menu bar icon

- [ ] **4.2 Test Menu Bar**
  - [ ] Click Clipso menu bar icon
  - [ ] Should show menu with options
  - [ ] If not Pro user, should see "Upgrade to Pro..." option
  - [ ] Click "Upgrade to Pro..."

- [ ] **4.3 Test Checkout Link**
  - [ ] Should see dropdown menu with:
    - [ ] "Lifetime Pro ($29.99)"
    - [ ] "Annual Pro ($7.99/year)"
  - [ ] Click one of them
  - [ ] Should open Lemon Squeezy checkout in browser
  - [ ] **Don't complete purchase yet** - just verify it opens

- [ ] **4.4 Test License Activation UI**
  - [ ] Close the app
  - [ ] Relaunch
  - [ ] Click menu bar → **Activate License...**
  - [ ] Should open window with:
    - [ ] Email field
    - [ ] License Key field
    - [ ] Two buttons to purchase lifetime/annual
  - [ ] Close window

- [ ] **4.5 Test Settings View**
  - [ ] Open System Preferences/Settings
  - [ ] Navigate to **Clipso** section
  - [ ] Should show **License** section with:
    - [ ] "Free Plan" status
    - [ ] Upgrade button
    - [ ] "Activate License..." button

---

## Section 5: Test Purchase Flow (Optional but Recommended)

### Prerequisites
- [ ] All previous sections completed
- [ ] Actual test purchase budget (small amount like $0.01 in test mode if available)

### Steps

- [ ] **5.1 Create Test Purchase**
  - [ ] Click Clipso menu → "Upgrade to Pro..." → "Lifetime Pro"
  - [ ] Opens Lemon Squeezy checkout
  - [ ] Fill in test payment info:
    - Card: `4111 1111 1111 1111` (test card)
    - Expiry: Any future date
    - CVC: Any 3 digits
    - Email: Your email
  - [ ] Click **Purchase**
  - [ ] Should see confirmation page

- [ ] **5.2 Check Email**
  - [ ] Check email (sent by Lemon Squeezy)
  - [ ] Should contain **license key**
  - [ ] **Copy the license key**

- [ ] **5.3 Activate License in App**
  - [ ] Return to Clipso
  - [ ] Click menu → "Activate License..."
  - [ ] Fill in:
    - Email: Your email (from purchase)
    - License Key: Key from email
  - [ ] Click "Activate License"
  - [ ] Should show success message
  - [ ] License should activate

- [ ] **5.4 Verify Pro Status**
  - [ ] Close and reopen Settings
  - [ ] License section should show:
    - [ ] ✓ Lifetime Pro (instead of Free Plan)
    - [ ] Your email
    - [ ] Deactivate button (instead of Upgrade)

- [ ] **5.5 Verify Feature Access**
  - [ ] In clipboard view, check Pro features work:
    - [ ] Semantic search available (if implemented)
    - [ ] Context detection active (if implemented)
    - [ ] More than 250 items in history

---

## Section 6: Production Checklist

Before shipping to users:

- [ ] [ ] Store ID matches exactly in code
- [ ] [ ] Lifetime Product ID matches exactly
- [ ] [ ] Annual Product ID matches exactly
- [ ] [ ] Both products created in Lemon Squeezy
- [ ] [ ] License keys enabled on both products
- [ ] [ ] Test purchase and activation works
- [ ] [ ] License persists after app restart
- [ ] [ ] License can be deactivated
- [ ] [ ] Banking info added to Lemon Squeezy (for payments)
- [ ] [ ] Refund policy documented
- [ ] [ ] Customer support contact info available

---

## Configuration Reference

### IDs You'll Need

| Item | Value | Where to Get |
|------|-------|-------------|
| Store ID | `12345` | Lemon Squeezy dashboard after creating store |
| Lifetime Product ID | `123456` | Lemon Squeezy product details page |
| Annual Product ID | `654321` | Lemon Squeezy product details page |
| Lifetime Price | $29.99 | Set in Lemon Squeezy product settings |
| Annual Price | $7.99/year | Set in Lemon Squeezy product settings |

### Code File Locations

| File | Lines to Update |
|------|-----------------|
| `Clipso/Managers/LemonSqueezyManager.swift` | 23-28 (Store ID, Product IDs) |

---

## Troubleshooting

### Issue: App won't build after updating IDs
**Check:**
- [ ] No typos in IDs
- [ ] IDs are strings (in quotes)
- [ ] No extra spaces or characters

### Issue: Checkout doesn't open when clicking "Upgrade to Pro"
**Check:**
- [ ] Store ID is correct
- [ ] Product IDs are correct
- [ ] URL construction: `https://[storeId].lemonsqueezy.com/checkout/buy/[productId]`
- [ ] Test URL in browser manually

### Issue: License activation shows "Invalid license key"
**Check:**
- [ ] Email matches purchase email exactly
- [ ] License key is copied correctly (case-sensitive)
- [ ] No extra spaces in key
- [ ] License hasn't been deactivated already

### Issue: License doesn't persist after app restart
**Check:**
- [ ] Check Keychain access isn't blocked
- [ ] Verify System Preferences → Security & Privacy allows Clipso

### Issue: Settings shows "License keys not generating"
**Check:**
- [ ] In Lemon Squeezy, product has license keys enabled
- [ ] License key settings are configured
- [ ] Product is published/active

---

## Next Steps

1. **Complete Sections 1-3** above (Lemon Squeezy + Code setup)
2. **Build the app** (Cmd+B in Xcode)
3. **Test basic flows** (Section 4)
4. **Optionally test purchase** (Section 5)
5. **Review production checklist** (Section 6)
6. **Deploy!**

---

## Support & Resources

- **Lemon Squeezy Docs**: https://docs.lemonsqueezy.com
- **License Key API**: https://docs.lemonsqueezy.com/api/license-keys
- **Dashboard**: https://app.lemonsqueezy.com

---

## Quick Reference

**Your IDs** (fill in after setup):
```
Store ID: ________________
Lifetime Product ID: ________________
Annual Product ID: ________________
```

**Test Data** (for testing):
```
Test Email: ________________
Test License Key: ________________
```

Good luck with your Clipso launch! 🚀
