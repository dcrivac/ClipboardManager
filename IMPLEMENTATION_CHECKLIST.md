# RevenueCat + Apple IAP Implementation Checklist

Complete all three sections in order. Estimated time: 1-2 hours.

---

## Section 1: Apple App Store Connect Setup (30 min)

### Prerequisites
- Active Apple Developer account with paid membership
- App signing certificate (or create new)

### Steps

- [ ] **1.1 Create Bundle ID**
  - [ ] Go to [developer.apple.com/account](https://developer.apple.com/account)
  - [ ] Navigate to **Certificates, Identifiers & Profiles** → **Identifiers**
  - [ ] Click **+** button
  - [ ] Select **App IDs** and click **Continue**
  - [ ] Fill in:
    - Description: `Clipso`
    - Bundle ID: `com.clipso`
  - [ ] Check **In-App Purchase** capability
  - [ ] Click **Register**, then **Done**

- [ ] **1.2 Create App in App Store Connect**
  - [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
  - [ ] Go to **My Apps** → **+** → **New App**
  - [ ] Fill in:
    - Platform: **macOS**
    - Name: `Clipso`
    - Bundle ID: Select `com.clipso` from dropdown
    - SKU: `clipso-01`
  - [ ] Click **Create**

- [ ] **1.3 Add Lifetime Purchase Product**
  - [ ] In App Store Connect, go to **Clipso** app
  - [ ] Navigate to **In-App Purchases**
  - [ ] Click **+** button
  - [ ] Select **Non-Consumable**
  - [ ] Fill in:
    - Reference Name: `Lifetime Pro`
    - Product ID: `com.clipso.lifetime` **[EXACT - case sensitive]**
    - Pricing: $29.99 (or your preferred tier)
    - Localized metadata:
      - Display Name: `Lifetime Pro`
      - Description: `Unlock all Pro features forever`
  - [ ] Click **Create**
  - [ ] Set pricing tier in **Pricing and Availability** section

- [ ] **1.4 Add Annual Subscription Product**
  - [ ] In **In-App Purchases**, click **+** button again
  - [ ] Select **Auto-Renewable Subscription**
  - [ ] Fill in:
    - Reference Name: `Annual Pro`
    - Product ID: `com.clipso.annual` **[EXACT - case sensitive]**
  - [ ] In **Subscription Duration**, select **1 Year**
  - [ ] Pricing: $7.99 (or your preferred tier)
  - [ ] Localized metadata:
    - Display Name: `Annual Pro`
    - Description: `Unlock all Pro features for one year`
  - [ ] Click **Create**
  - [ ] In **Renewal** section, make sure **Auto-Renewable** is ON
  - [ ] Set pricing tier

- [ ] **1.5 Create Sandbox Test Account**
  - [ ] Go to **Users and Access** → **Sandbox**
  - [ ] Click **+** under "Sandbox Testers"
  - [ ] Fill in test account details:
    - First Name: `Test`
    - Last Name: `User`
    - Email: `test+clipso@yourmail.com` (must be unique, can be fake but receive emails)
    - Password: Generate strong password
    - Security Questions: Fill in
  - [ ] Click **Create**
  - [ ] **Save this account info** - you'll need it for testing

- [ ] **1.6 Add Banking Information**
  - [ ] Go to **Agreements, Tax, and Banking**
  - [ ] Add banking details to receive payments
  - [ ] This is required before going live (not needed for testing)

---

## Section 2: RevenueCat Setup (20 min)

### Steps

- [ ] **2.1 Create RevenueCat Account**
  - [ ] Go to [revenuecat.com/dashboard](https://dashboard.revenuecat.com)
  - [ ] Sign up for free account
  - [ ] Create new **Project**: `Clipso`
  - [ ] Save your API key (starts with `pk_`)

- [ ] **2.2 Add Apple as Payment Processor**
  - [ ] In RevenueCat Dashboard, go to **Project Settings** → **Integrations**
  - [ ] Click **Apple App Store**
  - [ ] You'll need your App Store Connect credentials (will prompt later)

- [ ] **2.3 Add Products to RevenueCat**
  - [ ] Go to **Products** in left sidebar
  - [ ] Click **Add Product**
  - [ ] For **Lifetime**:
    - Product ID: `com.clipso.lifetime` **[EXACT]**
    - Display Name: `Lifetime Pro`
    - Type: **Consumable** (or Non-Consumable)
    - Click **Add Product**

  - [ ] Click **Add Product** again for **Annual**:
    - Product ID: `com.clipso.annual` **[EXACT]**
    - Display Name: `Annual Pro`
    - Type: **Subscription**
    - Duration: **1 Year**
    - Click **Add Product**

- [ ] **2.4 Create "pro" Entitlement**
  - [ ] Go to **Entitlements** in left sidebar
  - [ ] Click **Add Entitlement**
  - [ ] Name: `pro` **[EXACT]**
  - [ ] Click **Add Entitlement**

- [ ] **2.5 Map Products to Entitlement**
  - [ ] Go back to **Products**
  - [ ] Click on `com.clipso.lifetime`
  - [ ] Scroll to **Entitlements** section
  - [ ] Add entitlement: Select `pro`
  - [ ] Repeat for `com.clipso.annual` product

- [ ] **2.6 Link with App Store Connect** (requires credentials)
  - [ ] In RevenueCat, go to **Project Settings** → **Integrations** → **Apple**
  - [ ] You'll be prompted to sign in with App Store Connect credentials
  - [ ] Complete the OAuth flow

- [ ] **2.7 Copy Your API Key**
  - [ ] Go to **Project Settings** → **API Keys**
  - [ ] Copy the **Public API Key** (starts with `pk_`)
  - [ ] Store safely - you'll need it next

---

## Section 3: Xcode Project Configuration (40 min)

### Step 3.1: Update RevenueCatManager with API Key

- [ ] Open `Clipso/Managers/RevenueCatManager.swift`
- [ ] Find line 24: `private let apiKey = "YOUR_REVENUECAT_API_KEY"`
- [ ] Replace with your actual RevenueCat API key:
  ```swift
  private let apiKey = "pk_your_actual_key_here"
  ```
- [ ] **Save file** (Cmd+S)

### Step 3.2: Update Xcode Project Settings

- [ ] Open `Clipso.xcodeproj` in Xcode
- [ ] Select **Clipso** target
- [ ] Go to **General** tab
  - [ ] **Identity** section:
    - [ ] Bundle Identifier: `com.clipso`
    - [ ] Team: Select your Apple Developer team
    - [ ] Version: `1.0`
    - [ ] Build: `1`

### Step 3.3: Add In-App Purchase Capability

- [ ] Still in Clipso target, go to **Signing & Capabilities** tab
- [ ] Click **+ Capability**
- [ ] Search for and add: **In-App Purchase**
- [ ] Verify it appears in the capabilities list

### Step 3.4: Add StoreKit Configuration for Testing

- [ ] In Xcode, **File** → **New** → **StoreKit Configuration**
- [ ] Name it: `Clipso`
- [ ] Click **Create**
- [ ] In the new file, add two products:

  **Product 1: Lifetime**
  - [ ] Click **+** button
  - [ ] Type: **Non-Consumable**
  - [ ] Product ID: `com.clipso.lifetime`
  - [ ] Reference Name: `Lifetime Pro`
  - [ ] Price: $29.99
  - [ ] Click **Add**

  **Product 2: Annual**
  - [ ] Click **+** button
  - [ ] Type: **Auto-Renewable Subscription**
  - [ ] Product ID: `com.clipso.annual`
  - [ ] Reference Name: `Annual Pro`
  - [ ] Subscription Duration: **Annual**
  - [ ] Price: $7.99
  - [ ] Click **Add**

- [ ] **Save** the StoreKit configuration (Cmd+S)

### Step 3.5: Configure Scheme to Use StoreKit

- [ ] Go to **Product** menu → **Scheme** → **Edit Scheme...**
- [ ] Select **Run** on left sidebar
- [ ] Go to **Options** tab
- [ ] Find **StoreKit Configuration** dropdown
- [ ] Select **Clipso** (the file you just created)
- [ ] Click **Close**

### Step 3.6: Add RevenueCat SDK via SPM

- [ ] **File** → **Add Packages**
- [ ] Enter repository URL:
  ```
  https://github.com/RevenueCat/purchases-ios.git
  ```
- [ ] Select version: **Up to Next Major** (or latest stable)
- [ ] Click **Add Package**
- [ ] When prompted, select **Clipso** target
- [ ] Click **Add Package**

### Step 3.7: Verify Info.plist Permissions

- [ ] Open `Clipso/Info.plist`
- [ ] Verify these keys exist (they should already):
  ```xml
  <key>NSAppleEventsUsageDescription</key>
  <string>Monitor clipboard changes for clipboard history</string>

  <key>NSAccessibilityUsageDescription</key>
  <string>Detect active application for context detection</string>
  ```

---

## Section 4: Local Testing (20 min)

### Prerequisites
- [ ] All steps 1-3 completed
- [ ] Xcode scheme configured with StoreKit Configuration
- [ ] RevenueCat API key added to code

### Test Flow

- [ ] **Build and Run**
  - [ ] Select iPhone or Mac Catalyst simulator (or Mac if building for Mac)
  - [ ] Press **Play** button in Xcode (⌘+R)
  - [ ] App should launch with StoreKit enabled

- [ ] **Test Free Tier**
  - [ ] Verify app shows "Free Plan" in menu bar
  - [ ] Check that free limits apply (250 items, 30-day retention)

- [ ] **Test Paywall**
  - [ ] Click "Upgrade to Pro..." from menu bar
  - [ ] Paywall should open showing two products:
    - [ ] Lifetime Pro ($29.99)
    - [ ] Annual Pro ($7.99)
  - [ ] Verify both products are clickable

- [ ] **Test Purchase Flow**
  - [ ] Click on "Lifetime Pro" product
  - [ ] Click "Purchase" button
  - [ ] StoreKit payment dialog should appear
  - [ ] Complete purchase with sandbox credentials
  - [ ] Verify license changes to "Lifetime Pro" in settings
  - [ ] Verify Pro features are now accessible

- [ ] **Test Purchase Restoration**
  - [ ] From menu bar, click "Restore Purchases..."
  - [ ] Verify it recognizes your test purchase
  - [ ] Pro status should still show in settings

- [ ] **Test Annual Subscription**
  - [ ] Create new test user (or reset app data)
  - [ ] Repeat paywall test with Annual option
  - [ ] Verify annual subscription shows in settings
  - [ ] Verify renewal date is 1 year from purchase

---

## Section 5: Sandbox Testing with Real Account (Optional, 15 min)

### Prerequisites
- [ ] Sandbox test account created (Section 1.5)
- [ ] Built and signed app executable

### Steps

- [ ] **Sign Out of Real Apple ID**
  - [ ] System Preferences → Apple ID
  - [ ] Sign out of your personal Apple ID

- [ ] **Sign In with Sandbox Account**
  - [ ] Sign in using sandbox test account from Section 1.5
  - [ ] Accept any prompts

- [ ] **Run App and Test**
  - [ ] Launch built Clipso app
  - [ ] Attempt purchase
  - [ ] Test payment dialog
  - [ ] Verify license activation

- [ ] **Sign Back In**
  - [ ] Return to System Preferences
  - [ ] Sign back in with your real Apple ID

---

## Section 6: Pre-Production Checklist

### Before Shipping

- [ ] [ ] RevenueCat API key is secure (not hardcoded in production)
- [ ] [ ] All product IDs match exactly between:
  - [ ] App Store Connect
  - [ ] RevenueCat
  - [ ] RevenueCatManager.swift
- [ ] [ ] Entitlement "pro" is properly configured in RevenueCat
- [ ] [ ] Both products mapped to "pro" entitlement
- [ ] [ ] Xcode signing certificate is valid
- [ ] [ ] Bundle ID matches everywhere
- [ ] [ ] Tested with StoreKit configuration locally
- [ ] [ ] Tested with sandbox account
- [ ] [ ] Verified purchase flow works end-to-end
- [ ] [ ] Verified license gating works (Pro features unlock)

---

## Troubleshooting

### Issue: "Products not loading" in Paywall
**Check:**
- [ ] API key is correct and not expired
- [ ] Products exist in RevenueCat dashboard
- [ ] Product IDs match exactly (case-sensitive)
- [ ] RevenueCat SDK is properly imported

### Issue: StoreKit Configuration not working
**Check:**
- [ ] Scheme is configured to use StoreKit file
- [ ] Running on simulator (not physical device)
- [ ] Building for correct target

### Issue: Can't find products in App Store Connect
**Check:**
- [ ] Bundle ID matches exactly
- [ ] Navigating to correct app in App Store Connect
- [ ] App is fully set up (required metadata completed)

### Issue: Sandbox account not working
**Check:**
- [ ] Account is under "Sandbox Testers" (not regular accounts)
- [ ] Signed out of real Apple ID before testing
- [ ] Internet connection is working

---

## Quick Reference

| Item | Value |
|------|-------|
| Lifetime Product ID | `com.clipso.lifetime` |
| Annual Product ID | `com.clipso.annual` |
| Entitlement Name | `pro` |
| Bundle ID | `com.clipso` |
| RevenueCat Docs | https://docs.revenuecat.com |
| Apple IAP Docs | https://developer.apple.com/in-app-purchase |

**Next Step:** Start with Section 1, work through systematically. Most issues come from mismatched product IDs or incomplete App Store Connect setup.
