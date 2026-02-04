# Quick Start: Deploy Clipso Backend in 10 Minutes

Follow these steps to get your backend live and ready for payments.

## ✅ Pre-Deployment Checklist

Your code is ready! All files are committed and pushed to:
- **Repository**: `https://github.com/dcrivac/Clipso`
- **Branch**: `claude/lifetime-license-friend-ujPwz`
- **Backend location**: `backend/` directory

## 🚀 Step-by-Step Deployment

### 1. Create Railway Account (2 minutes)

1. Go to [railway.app](https://railway.app)
2. Click **"Login"**
3. **Sign in with GitHub**
4. Authorize Railway

**You get $5 free credit!**

### 2. Deploy from GitHub (3 minutes)

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose: **`dcrivac/Clipso`**
4. Branch: **`claude/lifetime-license-friend-ujPwz`**

### 3. Configure Backend (1 minute)

After Railway creates the service:

1. Click on the service
2. Go to **Settings** → **Build & Deploy**
3. Set **Root Directory**: `backend`
4. Set **Start Command**: `node server.js`
5. Save

### 4. Add PostgreSQL (1 minute)

1. Click **"+ New"** in your project
2. Select **"Database"** → **"PostgreSQL"**
3. Wait for database to provision

### 5. Set Up Email Service (2 minutes)

**Get Resend API Key:**

1. Go to [resend.com](https://resend.com)
2. Sign up (100 emails/day free)
3. Go to [API Keys](https://resend.com/api-keys)
4. Click **"Create API Key"**
5. Copy the key (starts with `re_`)

### 6. Set Environment Variables (1 minute)

In Railway, click your backend service → **Variables** tab:

Add these variables:

| Variable | Value | Where to Get It |
|----------|-------|-----------------|
| `RESEND_API_KEY` | `re_xxxxxxxxxxxx` | [resend.com/api-keys](https://resend.com/api-keys) |
| `EMAIL_FROM` | `Clipso <licenses@clipso.app>` | Your choice |
| `PADDLE_WEBHOOK_SECRET` | Get after Paddle setup | [Paddle Dashboard](https://vendors.paddle.com) |
| `NODE_ENV` | `production` | Just type it |

**Note:** You'll add `PADDLE_WEBHOOK_SECRET` after setting up Paddle in next step.

### 7. Generate Domain & Deploy (Auto)

1. Go to **Settings** → **Domains**
2. Click **"Generate Domain"**
3. Copy URL (e.g., `https://clipso-production.up.railway.app`)
4. Railway automatically deploys!

Wait ~2 minutes for deployment to complete.

### 8. Load Database Schema (1 minute)

**Option A: Via Railway Web Interface**

1. Click **PostgreSQL** service
2. Go to **Data** tab
3. Click **Query**
4. Copy contents of `backend/schema-fixed.sql`
5. Paste and click **Run Query**

**Option B: Via Command Line** (if you have psql)

```bash
# Get connection URL from Railway PostgreSQL service
psql "your-connection-url" < backend/schema-fixed.sql
```

### 9. Test Backend

```bash
curl https://your-railway-url.com/health
```

Expected:
```json
{"status":"ok","timestamp":"2024-02-04T..."}
```

✅ **If you see this, your backend is live!**

---

## 🎫 Set Up Paddle Payments

### 1. Create Paddle Account

1. Go to [paddle.com](https://paddle.com)
2. Sign up for Seller account
3. Complete verification
4. Go to Dashboard

### 2. Get Webhook Secret

1. In Paddle: **Developer Tools** → **Notifications**
2. Copy your **Webhook Secret Key**
3. Add to Railway variables: `PADDLE_WEBHOOK_SECRET=pdl_ntfset_xxxxx`

### 3. Configure Webhook URL

1. In Paddle: **Developer Tools** → **Notifications**
2. Set **Destination URL**: `https://your-railway-url.com/webhook/paddle`
3. Enable events:
   - ✅ `transaction.completed`
   - ✅ `transaction.updated`
   - ✅ `subscription.activated`
   - ✅ `subscription.cancelled`
4. Save

### 4. Create Products

**Lifetime License:**
1. Catalog → Products → **Create Product**
2. Name: "Clipso Pro - Lifetime"
3. Create Price: $29.99 USD, One-time
4. Copy **Price ID** (e.g., `pri_01xxx`)

**Annual License:**
1. Create another product: "Clipso Pro - Annual"
2. Create Price: $7.99 USD, Annual
3. Copy **Price ID**

### 5. Update Clipso App

Edit `Managers/PaddleConfig.swift`:

```swift
static let productionVendorId = "live_your_vendor_id"
static let productionLifetimePriceId = "pri_your_lifetime_price_id"
static let productionAnnualPriceId = "pri_your_annual_price_id"
static let useSandbox = false
```

Edit `Managers/LicenseManager.swift`:

```swift
private let baseURL = "https://your-railway-url.com"
```

---

## 🧪 Test End-to-End

### 1. Test License Activation

Using your friend's license:

```bash
curl -X POST https://your-railway-url.com/api/licenses/activate \
  -H "Content-Type: application/json" \
  -d '{
    "license_key": "CLIPSO-72C8-26A5-B3FE-6166",
    "device_id": "test-mac-001",
    "device_name": "Test MacBook Pro",
    "device_model": "MacBookPro18,1",
    "os_version": "macOS 14.2",
    "app_version": "1.0.3"
  }'
```

Expected: `{"success": true, ...}`

### 2. Test License Retrieval

```bash
curl -X POST https://your-railway-url.com/api/licenses/retrieve \
  -H "Content-Type: application/json" \
  -d '{"email": "Everydayhustlehub@gmail.com"}'
```

Your friend should receive an email with their license!

### 3. Test in App

1. Open Clipso app
2. Go to **Settings** → **License**
3. Enter: `Everydayhustlehub@gmail.com`
4. Enter: `CLIPSO-72C8-26A5-B3FE-6166`
5. Click **Activate License**

Should show: ✅ "License activated successfully"

---

## 📊 Monitor Your Backend

### View Logs

Railway service → **Observability** tab

### Check Database

PostgreSQL service → **Data** tab

```sql
-- Recent licenses
SELECT * FROM licenses ORDER BY created_at DESC LIMIT 5;

-- Active devices
SELECT * FROM devices WHERE is_active = TRUE ORDER BY activated_at DESC;

-- Webhook events
SELECT event_type, processed, created_at FROM webhook_events ORDER BY created_at DESC LIMIT 10;
```

---

## 💰 Costs

- **Railway Hobby**: $5/month (includes PostgreSQL)
- **Resend Email**: Free (100 emails/day)
- **Paddle Fees**: 5% + $0.50 per transaction
- **Total Monthly**: $5

**First $5 free for new Railway users!**

---

## 🎉 You're Live!

Your production flow:

1. Customer clicks "Buy" → Paddle checkout
2. Customer pays
3. Paddle webhook → Your backend
4. Backend creates license
5. **Customer gets email with license key** ✉️
6. Customer activates in app
7. Pro features unlock! 🚀

---

## 📚 Detailed Guides

- **Railway Web Deploy**: `backend/DEPLOY_VIA_WEB.md`
- **Paddle Setup**: `PADDLE_SETUP_GUIDE.md`
- **Full Deployment**: `DEPLOYMENT_GUIDE.md`
- **Backend API**: `backend/README.md`

---

## 🆘 Need Help?

- **Railway Issues**: [discord.gg/railway](https://discord.gg/railway)
- **Paddle Support**: [paddle.com/support](https://paddle.com/support)
- **Clipso Issues**: [github.com/dcrivac/Clipso/issues](https://github.com/dcrivac/Clipso/issues)

---

## ✅ Deployment Checklist

- [ ] Railway account created
- [ ] Backend deployed from GitHub
- [ ] PostgreSQL added
- [ ] Database schema loaded
- [ ] Environment variables set
- [ ] Resend email configured
- [ ] Domain generated
- [ ] Health check passes
- [ ] Paddle account created
- [ ] Webhook configured
- [ ] Products created
- [ ] App updated with URLs
- [ ] Test purchase completed
- [ ] Email delivery tested

**Good luck! 🚀**
