# 🎉 Deploy Your Backend NOW - 100% FREE

**Quick reference card for deploying to Render.com (completely free)**

---

## ⚡ 5-Minute Quick Start

### 1. Render Account
```
→ Go to: render.com
→ Click: "Get Started for Free"
→ Sign up with GitHub
→ No credit card needed!
```

### 2. Create Database
```
→ Click: "New +" → "PostgreSQL"
→ Name: clipso-database
→ Database: clipso_licenses
→ Plan: FREE
→ Click: "Create Database"
```

### 3. Load Schema
```
→ Database → "Shell" tab
→ Copy/paste: backend/schema-fixed.sql
→ Press Enter
```

### 4. Deploy Backend
```
→ Click: "New +" → "Web Service"
→ Connect: dcrivac/Clipso
→ Branch: claude/lifetime-license-friend-ujPwz
→ Root Directory: backend
→ Build: npm install
→ Start: node server.js
→ Plan: FREE
```

### 5. Set Environment Variables
```
In your web service → Environment:

DATABASE_URL = (copy from your PostgreSQL service)
NODE_ENV = production
RESEND_API_KEY = (get from resend.com - free)
EMAIL_FROM = Clipso <licenses@clipso.app>
```

### 6. Get Free Email
```
→ Go to: resend.com
→ Sign up (100 emails/day free)
→ Create API key
→ Copy key (starts with re_)
→ Add to Render environment
```

### 7. Your URL
```
→ Service → Settings → Copy URL
→ Example: https://clipso-backend.onrender.com
```

### 8. Test
```bash
curl https://your-url.onrender.com/health
```

✅ **Done! Your backend is live at $0/month**

---

## 📋 What You Need

| Item | Where to Get | Cost |
|------|--------------|------|
| Render Account | [render.com](https://render.com) | **FREE** |
| Resend Account | [resend.com](https://resend.com) | **FREE** |
| Paddle Account | [paddle.com](https://paddle.com) | Pay per sale only |

**Total: $0/month** (only Paddle fees on sales)

---

## 🎯 Insert Your Friend's License

After database is running:

```sql
-- In Render database Shell tab:
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
);
```

---

## 🔧 Update Clipso App

Edit `Managers/LicenseManager.swift`:

```swift
private let baseURL = "https://your-render-url.onrender.com"
```

Rebuild and test!

---

## ⚠️ One Limitation

**Free tier sleeps after 15 minutes of no activity**
- First request takes ~30 seconds to wake up
- After that, runs normally

**Keep it awake (optional):**
1. Go to [cron-job.org](https://cron-job.org) (free)
2. Add job: `https://your-url.onrender.com/health`
3. Every 14 minutes
4. Never sleeps!

---

## 💡 Quick Checks

✅ **Backend works:**
```bash
curl https://your-url.onrender.com/health
# Should return: {"status":"ok",...}
```

✅ **License activates:**
```bash
curl -X POST https://your-url.onrender.com/api/licenses/activate \
  -H "Content-Type: application/json" \
  -d '{"license_key":"CLIPSO-72C8-26A5-B3FE-6166","device_id":"test1","device_name":"Test Mac","device_model":"Mac","os_version":"14","app_version":"1.0.3"}'
# Should return: {"success":true,...}
```

✅ **Email works:**
```bash
curl -X POST https://your-url.onrender.com/api/licenses/retrieve \
  -H "Content-Type: application/json" \
  -d '{"email":"Everydayhustlehub@gmail.com"}'
# Should return: {"success":true,...}
```

---

## 📚 Full Guides

- **FREE_HOSTING_GUIDE.md** - Complete free hosting guide
- **QUICK_START_DEPLOYMENT.md** - Alternative options
- **backend/DEPLOY_VIA_WEB.md** - Detailed instructions

---

## 🎉 You're Done!

Your backend is now:
- ✅ Live on the internet
- ✅ 100% free
- ✅ Ready for payments
- ✅ Sending license emails
- ✅ No credit card needed

**Start selling!** 🚀
