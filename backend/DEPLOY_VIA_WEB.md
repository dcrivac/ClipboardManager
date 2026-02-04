# Deploy Clipso Backend via Railway Web Interface

Since Railway CLI can't be used in this environment, here's how to deploy using Railway's web interface.

## Method 1: Deploy via GitHub (Recommended - 10 minutes)

### Prerequisites
- GitHub account
- Railway account (free tier available)

### Step 1: Push Code to GitHub

Your code is already on GitHub at: `https://github.com/dcrivac/Clipso`

The backend is in the `backend/` directory with branch: `claude/lifetime-license-friend-ujPwz`

### Step 2: Create Railway Account

1. Go to [railway.app](https://railway.app)
2. Click **"Login"**
3. Sign in with GitHub
4. Authorize Railway to access your repositories

### Step 3: Create New Project

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose repository: **`dcrivac/Clipso`**
4. Select branch: **`claude/lifetime-license-friend-ujPwz`**
5. Railway will auto-detect Node.js project

### Step 4: Configure Root Directory

Railway needs to know the backend is in a subdirectory:

1. Click on your service
2. Go to **Settings** tab
3. Scroll to **"Build & Deploy"**
4. Set **Root Directory**: `backend`
5. Set **Start Command**: `node server.js`
6. Click **"Save Changes"**

### Step 5: Add PostgreSQL Database

1. Click **"+ New"** button in your project
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway automatically creates database and sets `DATABASE_URL`

### Step 6: Set Environment Variables

1. Click on your backend service
2. Go to **"Variables"** tab
3. Click **"+ New Variable"** and add:

```
PADDLE_WEBHOOK_SECRET=your_paddle_webhook_secret_here
RESEND_API_KEY=your_resend_api_key_here
EMAIL_FROM=Clipso <licenses@clipso.app>
NODE_ENV=production
```

**Important:** Get these values from:
- **Paddle webhook secret**: [Paddle Dashboard → Developer Tools → Webhooks](https://vendors.paddle.com)
- **Resend API key**: [resend.com/api-keys](https://resend.com/api-keys) (sign up free)

4. Click **"Add"** for each variable

### Step 7: Deploy

Railway automatically deploys when you add the service. If not:

1. Go to **"Deployments"** tab
2. Click **"Deploy"** on latest commit
3. Wait for deployment to complete (~2 minutes)

### Step 8: Get Your Backend URL

1. Go to **"Settings"** tab
2. Scroll to **"Domains"**
3. Click **"Generate Domain"**
4. Copy the URL (e.g., `https://clipso-production.up.railway.app`)

### Step 9: Load Database Schema

1. Click on your **PostgreSQL** service
2. Go to **"Data"** tab
3. Click **"Query"**
4. Copy and paste the contents of `backend/schema-fixed.sql`
5. Click **"Run Query"**

**Or connect via command line:**

```bash
# Railway provides a connection string in the PostgreSQL service
# Copy "PostgreSQL Connection URL" from the Connect tab
psql "your-connection-url-here" < backend/schema-fixed.sql
```

### Step 10: Verify Deployment

Test your backend:

```bash
curl https://your-railway-url.com/health
```

Expected response:
```json
{"status":"ok","timestamp":"2024-01-24T..."}
```

## Method 2: Deploy via Railway CLI (When Available)

If you have Railway CLI available on your local machine:

```bash
# Install
npm install -g @railway/cli

# Login
railway login

# Navigate to backend
cd backend

# Initialize project
railway init

# Add PostgreSQL
railway add --plugin postgresql

# Deploy
railway up

# Load schema
railway connect postgres
\i schema-fixed.sql
\q

# Get URL
railway domain
```

## Method 3: Alternative Hosting (If Railway Doesn't Work)

### Option A: Render.com

1. Go to [render.com](https://render.com)
2. Sign up with GitHub
3. Click **"New +"** → **"Web Service"**
4. Connect repository: `dcrivac/Clipso`
5. Set:
   - **Root Directory**: `backend`
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
6. Add PostgreSQL: **"New +"** → **"PostgreSQL"**
7. Set environment variables
8. Deploy

**Cost:** Free tier available, $7/month for paid tier

### Option B: Heroku

1. Go to [heroku.com](https://heroku.com)
2. Create new app
3. Add PostgreSQL add-on
4. Connect GitHub repository
5. Set root directory in `heroku.yml`:
   ```yaml
   build:
     docker:
       web: backend/Dockerfile
   ```
6. Deploy

**Cost:** $5/month Eco plan

### Option C: DigitalOcean App Platform

1. Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
2. Create new App
3. Connect GitHub
4. Select repository and branch
5. Set source directory to `backend`
6. Add PostgreSQL database
7. Deploy

**Cost:** $5/month

## Post-Deployment Checklist

After deployment completes:

- [ ] Backend URL is accessible
- [ ] Health check passes: `curl https://your-url.com/health`
- [ ] PostgreSQL database is connected
- [ ] Database schema is loaded
- [ ] Environment variables are set
- [ ] Email service configured (Resend/SendGrid)
- [ ] Paddle webhook URL configured
- [ ] Test license activation works

## Configure Paddle Webhook

1. Go to [Paddle Dashboard](https://vendors.paddle.com)
2. Developer Tools → Webhooks
3. Set Notification URL: `https://your-railway-url.com/webhook/paddle`
4. Copy webhook secret
5. Add to Railway environment variables: `PADDLE_WEBHOOK_SECRET=xxx`

## Update Clipso App

Edit `Managers/LicenseManager.swift`:

```swift
private let baseURL = "https://your-railway-url.com"
```

Rebuild and test the app.

## Testing

### Test License Activation

```bash
curl -X POST https://your-railway-url.com/api/licenses/activate \
  -H "Content-Type: application/json" \
  -d '{
    "license_key": "CLIPSO-72C8-26A5-B3FE-6166",
    "device_id": "test-device-123",
    "device_name": "Test MacBook",
    "device_model": "MacBookPro18,1",
    "os_version": "macOS 14.2",
    "app_version": "1.0.3"
  }'
```

### Test License Retrieval

```bash
curl -X POST https://your-railway-url.com/api/licenses/retrieve \
  -H "Content-Type: application/json" \
  -d '{"email": "Everydayhustlehub@gmail.com"}'
```

## Monitoring

### View Logs (Railway)

1. Click on your service
2. Go to **"Observability"** tab
3. View real-time logs

### Check Database

1. Click on PostgreSQL service
2. Go to **"Data"** tab
3. Run queries:

```sql
-- View all licenses
SELECT * FROM licenses ORDER BY created_at DESC;

-- View active devices
SELECT * FROM devices WHERE is_active = TRUE;

-- Check webhook events
SELECT * FROM webhook_events ORDER BY created_at DESC LIMIT 10;
```

## Troubleshooting

### Deployment Fails

**Check build logs:**
1. Go to Deployments tab
2. Click on failed deployment
3. View build logs

**Common issues:**
- Missing `package.json` in root directory → Set root directory to `backend`
- Port configuration → Railway sets `PORT` automatically
- Database connection → Check `DATABASE_URL` is set

### Backend Not Responding

**Check:**
1. Service is running (green status in Railway)
2. Domain is generated and accessible
3. Logs show no errors
4. Database connection is successful

### Email Not Sending

**Check:**
1. `RESEND_API_KEY` or `SENDGRID_API_KEY` is set
2. `EMAIL_FROM` is configured
3. Check email service dashboard for errors
4. View backend logs for email errors

## Support

- **Railway Docs**: [docs.railway.app](https://docs.railway.app)
- **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
- **Clipso Issues**: [github.com/dcrivac/Clipso/issues](https://github.com/dcrivac/Clipso/issues)

## Estimated Costs

- **Railway Hobby**: $5/month (includes PostgreSQL)
- **Resend Email**: Free (100 emails/day)
- **Total**: $5/month

First $5 credit free for new users!
