# Deploy Clipso Backend - 100% FREE Options

Complete guide to hosting your backend at **$0/month** with free tier services.

## 🎉 Best Free Option: Render.com

**Why Render:**
- ✅ **100% FREE** - No credit card required
- ✅ Free PostgreSQL database included
- ✅ Automatic HTTPS
- ✅ Easy GitHub deployment
- ✅ 750 hours/month free (enough for 24/7)
- ✅ No credit card needed to start

**Limitations:**
- Backend sleeps after 15 minutes of inactivity (takes 30 seconds to wake up)
- Perfect for small scale / getting started

---

## 🚀 Deploy to Render (10 Minutes - FREE)

### Step 1: Create Render Account

1. Go to [render.com](https://render.com)
2. Click **"Get Started for Free"**
3. Sign up with GitHub
4. **No credit card required!**

### Step 2: Create PostgreSQL Database

1. Click **"New +"** → **"PostgreSQL"**
2. Fill in:
   - **Name:** `clipso-database`
   - **Database:** `clipso_licenses`
   - **User:** `clipso`
   - **Region:** Choose closest to you
   - **Plan:** **FREE**
3. Click **"Create Database"**
4. Wait for database to provision (~2 minutes)

### Step 3: Get Database Connection String

1. Click on your database
2. Scroll to **"Connections"**
3. Copy **"Internal Database URL"** (starts with `postgresql://`)
4. Save this - you'll need it later!

### Step 4: Load Database Schema

**Option A: Via Render Dashboard**

1. In your database, click **"Shell"** tab
2. You're now in psql
3. Copy/paste the contents of `backend/schema-fixed.sql`
4. Press Enter to execute

**Option B: Via Command Line** (if you have psql)

```bash
psql "your-connection-url-from-render" < backend/schema-fixed.sql
```

### Step 5: Deploy Backend Service

1. Go back to Render dashboard
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository: **`dcrivac/Clipso`**
4. Configure:
   - **Name:** `clipso-backend`
   - **Branch:** `claude/lifetime-license-friend-ujPwz`
   - **Root Directory:** `backend`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `node server.js`
   - **Plan:** **FREE**

5. Click **"Advanced"** → Add Environment Variables:

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `DATABASE_URL` | (Paste the Internal Database URL from Step 3) |
| `RESEND_API_KEY` | (Get from resend.com - see below) |
| `EMAIL_FROM` | `Clipso <licenses@clipso.app>` |
| `PADDLE_WEBHOOK_SECRET` | (Get from Paddle - add later) |

6. Click **"Create Web Service"**

Wait ~5 minutes for first deployment.

### Step 6: Set Up Free Email (Resend)

1. Go to [resend.com](https://resend.com)
2. Sign up for **FREE account**
3. **100 emails/day free** - No credit card!
4. Go to [API Keys](https://resend.com/api-keys)
5. Create API key
6. Copy key (starts with `re_`)
7. Add to Render environment variables:
   - Go to your service → **Environment**
   - Add: `RESEND_API_KEY` = `re_your_key_here`
   - Click **"Save Changes"**

### Step 7: Get Your Backend URL

1. In Render, click your web service
2. Find **URL** at the top (e.g., `https://clipso-backend.onrender.com`)
3. Copy this URL

### Step 8: Test Your Backend

```bash
curl https://your-render-url.onrender.com/health
```

Expected:
```json
{"status":"ok","timestamp":"2024-02-04T..."}
```

✅ **Your backend is live and FREE!**

---

## 💰 Cost Breakdown: $0/month

| Service | Cost | What You Get |
|---------|------|--------------|
| Render Web Service | **FREE** | 750 hours/month, sleeps after 15min idle |
| Render PostgreSQL | **FREE** | 1GB database, 90 days history |
| Resend Email | **FREE** | 100 emails/day, 3,000/month |
| **TOTAL** | **$0** | Perfect for getting started! |

---

## 🔄 Alternative Free Options

### Option 2: Fly.io (FREE)

**What's Free:**
- 3 shared-cpu VMs
- 3GB storage
- 160GB outbound data transfer

**Deploy:**
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Deploy from backend directory
cd backend
flyctl launch --no-deploy
flyctl postgres create --name clipso-db
flyctl postgres attach clipso-db
flyctl deploy
```

### Option 3: Railway ($5 Credit FREE)

Railway gives **$5 free credit** = 1 month free, then $5/month

Good for testing before committing to paid hosting.

See `backend/DEPLOY_VIA_WEB.md` for Railway instructions.

### Option 4: Vercel + Supabase (100% FREE)

**Vercel** (Free frontend/backend)
- Deploy API routes
- Serverless functions
- Free SSL

**Supabase** (Free PostgreSQL)
- 500MB database
- 2GB bandwidth/month
- Free forever

This requires refactoring server.js to serverless functions.

---

## 📝 Insert Your Friend's License

After database is set up, insert the license:

```bash
# Connect to your Render database (from dashboard → Shell tab)
# Or use psql:
psql "your-render-database-url"

# Paste and run:
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

-- Verify:
SELECT * FROM licenses WHERE email = 'Everydayhustlehub@gmail.com';
```

---

## ⚙️ Configure Paddle Webhook

1. Go to [Paddle Dashboard](https://vendors.paddle.com)
2. Developer Tools → Webhooks
3. Set URL: `https://your-render-url.onrender.com/webhook/paddle`
4. Copy webhook secret
5. Add to Render environment variables:
   - `PADDLE_WEBHOOK_SECRET` = `pdl_ntfset_xxxxx`

---

## 🧪 Test Everything

### 1. Test License Activation

```bash
curl -X POST https://your-render-url.onrender.com/api/licenses/activate \
  -H "Content-Type: application/json" \
  -d '{
    "license_key": "CLIPSO-72C8-26A5-B3FE-6166",
    "device_id": "test-device-001",
    "device_name": "Test MacBook",
    "device_model": "MacBookPro18,1",
    "os_version": "macOS 14.2",
    "app_version": "1.0.3"
  }'
```

### 2. Test Email Retrieval

```bash
curl -X POST https://your-render-url.onrender.com/api/licenses/retrieve \
  -H "Content-Type: application/json" \
  -d '{"email": "Everydayhustlehub@gmail.com"}'
```

### 3. Test in Clipso App

Update `Managers/LicenseManager.swift`:
```swift
private let baseURL = "https://your-render-url.onrender.com"
```

Then test activation in the app!

---

## ⚠️ Free Tier Limitations

### Render Free Tier

**Good:**
- ✅ Perfect for getting started
- ✅ 750 hours/month = plenty for 24/7
- ✅ No credit card needed
- ✅ Scales automatically

**Limitations:**
- ⏱️ Sleeps after 15 minutes inactivity
- ⏱️ Takes ~30 seconds to wake up on first request
- 📊 Good for <100 users

**Wake-up Fix:**
Add a cron job to ping your backend every 14 minutes:
- Use [cron-job.org](https://cron-job.org) (free)
- Ping: `https://your-url.onrender.com/health`
- Every 14 minutes
- Keeps backend awake!

---

## 📈 When to Upgrade

Stay on free tier until you have:
- 50+ active users
- 500+ requests/day
- Need faster response times
- Need 99.9% uptime

Then upgrade to:
- **Render Starter:** $7/month (no sleep)
- **Railway Hobby:** $5/month (no sleep)
- **Fly.io Paid:** ~$5/month (no sleep)

---

## 🎯 Complete Free Stack

| Component | Service | Cost |
|-----------|---------|------|
| Backend API | Render.com | **FREE** |
| Database | Render PostgreSQL | **FREE** |
| Email | Resend | **FREE** |
| Payments | Paddle | 5% + $0.50/transaction |
| **Total** | | **$0/month** |

Only pay Paddle fees when you make sales!

---

## 🆘 Troubleshooting

### Backend Sleeps

**Symptom:** First request takes 30 seconds

**Solution:** Use [cron-job.org](https://cron-job.org) to ping `/health` every 14 minutes

### Database Connection Error

**Check:**
1. DATABASE_URL is set correctly
2. Use **Internal Database URL** from Render
3. Database is running (check Render dashboard)

### Email Not Sending

**Check:**
1. RESEND_API_KEY is set
2. Verified sender email in Resend dashboard
3. Check Resend dashboard for errors

---

## ✅ Free Deployment Checklist

- [ ] Render account created (free)
- [ ] PostgreSQL database created (free)
- [ ] Database schema loaded
- [ ] Backend service deployed (free)
- [ ] Environment variables set
- [ ] Resend account created (free)
- [ ] Email API key configured
- [ ] Backend URL obtained
- [ ] Health check passes
- [ ] Friend's license inserted
- [ ] License activation tested
- [ ] App updated with backend URL

**You're live at $0/month!** 🎉

---

## 📚 More Help

- **Render Docs:** [render.com/docs](https://render.com/docs)
- **Resend Docs:** [resend.com/docs](https://resend.com/docs)
- **Clipso Issues:** [github.com/dcrivac/Clipso/issues](https://github.com/dcrivac/Clipso/issues)

---

**Start with Render free tier. Upgrade only when you need to!**
