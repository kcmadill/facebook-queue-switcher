# Facebook Queue Switcher - Genesys Embedded App Deployment Guide

**Created:** December 9, 2025
**App Type:** Genesys Cloud Client App (Embedded Integration)

---

## Overview

This embedded app allows GSD team members to switch Facebook Messenger integration queues directly from the Genesys Cloud UI without using command line tools.

**Features:**
- ✅ Simple dropdown interface
- ✅ Shows current queue configuration
- ✅ Automatic queue lookup
- ✅ Instant switching (no flow publish needed)
- ✅ Secure (uses Genesys OAuth)
- ✅ All fields preserved (no data loss)

---

## Prerequisites

1. **Genesys Cloud Admin Access**
   - Ability to create integrations
   - Ability to assign integrations to users/groups

2. **Web Hosting** (Choose one option):
   - **Option A:** AWS S3 + CloudFront (Recommended for production)
   - **Option B:** GitHub Pages (Simple, free)
   - **Option C:** Internal web server with HTTPS

3. **Required Permissions for Users:**
   - `routing:queue:view`
   - `architect:datatable:view`
   - `architect:datatable:edit`

---

## Deployment Steps

### Option A: Deploy to AWS S3 + CloudFront (Recommended)

This is the recommended approach for production use.

#### Step 1: Create S3 Bucket

```bash
# Create bucket
aws s3 mb s3://gsd-facebook-queue-switcher --region us-east-1

# Enable static website hosting
aws s3 website s3://gsd-facebook-queue-switcher \
  --index-document index.html
```

#### Step 2: Upload App Files

```bash
cd C:\Users\madskilz80\dev\gsd-messenger-services\apps\facebook-queue-switcher

# Upload to S3
aws s3 cp index.html s3://gsd-facebook-queue-switcher/ \
  --content-type "text/html" \
  --cache-control "max-age=300"
```

#### Step 3: Create CloudFront Distribution

```bash
# Create distribution (save the output Domain Name)
aws cloudfront create-distribution \
  --origin-domain-name gsd-facebook-queue-switcher.s3.amazonaws.com \
  --default-root-object index.html
```

**Note:** Save the CloudFront domain name (e.g., `d1234abcd.cloudfront.net`)

#### Step 4: Configure CORS on S3

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["https://apps.usw2.pure.cloud"],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

Apply CORS:
```bash
aws s3api put-bucket-cors \
  --bucket gsd-facebook-queue-switcher \
  --cors-configuration file://cors.json
```

---

### Option B: Deploy to GitHub Pages (Quickest for Testing)

#### Step 1: Create Repository

1. Go to GitHub: https://github.com/new
2. Repository name: `facebook-queue-switcher`
3. Public repository
4. Create repository

#### Step 2: Push Files

```bash
cd C:\Users\madskilz80\dev\gsd-messenger-services\apps\facebook-queue-switcher

git init
git add index.html
git commit -m "Initial commit: Facebook Queue Switcher app"
git branch -M main
git remote add origin https://github.com/YOUR-ORG/facebook-queue-switcher.git
git push -u origin main
```

#### Step 3: Enable GitHub Pages

1. Go to repository Settings → Pages
2. Source: Deploy from branch
3. Branch: `main` / `root`
4. Click Save

**Your app URL:** `https://YOUR-ORG.github.io/facebook-queue-switcher/`

---

### Option C: Deploy to Internal Web Server

Requirements:
- HTTPS enabled (required by Genesys)
- Accessible from Genesys Cloud

1. Copy `index.html` to your web server
2. Ensure HTTPS is configured
3. Configure CORS headers:

```apache
# Apache .htaccess
Header set Access-Control-Allow-Origin "https://apps.usw2.pure.cloud"
Header set Access-Control-Allow-Methods "GET, HEAD"
```

---

## Configure in Genesys Cloud

### Step 1: Create Custom Client Application Integration

1. **Go to:** Genesys Cloud Admin → Integrations
2. **Click:** Install → Custom Client Application
3. **Configuration:**
   - **Name:** Facebook Queue Switcher
   - **Application URL:** Your deployed app URL (CloudFront/GitHub Pages/Internal)
   - **Application Type:** `widget`
   - **iframe Sandbox:** `allow-scripts allow-same-origin allow-forms`
   - **Group Filtering:** (Optional) Select GSD group

4. **Click:** Save

5. **Activate Integration:**
   - Click the integration
   - Status → Active

### Step 2: Grant Required Permissions

The app needs these OAuth scopes (automatically granted when user accesses):
- `routing:queue:view`
- `architect:datatable:view`
- `architect:datatable:edit`

**To verify/assign permissions:**
1. Go to Admin → People & Permissions → Roles
2. Find the role assigned to GSD users
3. Ensure it has:
   - View Queues
   - View Data Tables
   - Edit Data Tables

---

## Access the App

### For GSD Users:

**Method 1: Via Apps Menu**
1. In Genesys Cloud, click **Apps** (top navigation)
2. Find **Facebook Queue Switcher**
3. Click to open

**Method 2: Direct Link**
```
https://apps.usw2.pure.cloud/#/apps/YOUR-INTEGRATION-ID
```

**Method 3: Add to Toolbar** (Recommended)
1. Open the app
2. Click the ⋮ menu → Pin to toolbar
3. App appears in left sidebar for quick access

---

## Using the App

### Simple 3-Step Process:

1. **Select Integration**
   - Choose from: Asia North, Asia, Philippines, North America
   - Current queue configuration will display

2. **Select Target Queue**
   - Dropdown shows all available queues
   - Alphabetically sorted

3. **Click "Switch Queue"**
   - Confirmation message appears
   - Change takes effect immediately
   - No flow publish needed

---

## Troubleshooting

### App Won't Load

**Symptom:** Blank screen or "Failed to connect"

**Solutions:**
1. Verify app URL is accessible via HTTPS
2. Check CORS configuration on hosting
3. Ensure integration is Active in Genesys
4. Check browser console for errors (F12)

### "Failed to load queues"

**Symptom:** Queue dropdown shows error

**Solutions:**
1. Verify user has `routing:queue:view` permission
2. Check OAuth token is valid (re-login to Genesys)
3. Verify API access in Genesys Admin → Integrations

### "Failed to switch queue"

**Symptom:** Error when clicking Switch Queue button

**Solutions:**
1. Verify user has `architect:datatable:edit` permission
2. Ensure data table `Messaging_Routing_Config` exists
3. Check data table ID is correct in app code
4. Verify integration ID matches data table key

### CORS Errors

**Symptom:** Console shows CORS policy errors

**Solutions:**
1. Add proper CORS headers to hosting
2. Whitelist `https://apps.usw2.pure.cloud`
3. If using S3, apply CORS configuration
4. If using CDN, configure CORS on CDN level

---

## Updating the App

### Update Process:

1. **Edit** `index.html` locally
2. **Test** changes locally (see Testing section)
3. **Deploy** updated file:

**For S3/CloudFront:**
```bash
aws s3 cp index.html s3://gsd-facebook-queue-switcher/ \
  --cache-control "max-age=0"

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR-DIST-ID \
  --paths "/*"
```

**For GitHub Pages:**
```bash
git add index.html
git commit -m "Update app"
git push
```

---

## Testing Locally

### Before Deploying:

1. **Install local web server:**
```bash
npm install -g http-server
```

2. **Run locally:**
```bash
cd C:\Users\madskilz80\dev\gsd-messenger-services\apps\facebook-queue-switcher
http-server -p 8080 --cors
```

3. **Open:** http://localhost:8080

**Note:** Full OAuth won't work locally - deploy to test with real Genesys integration.

---

## Security Considerations

### Best Practices:

1. **HTTPS Only**
   - Never deploy over HTTP
   - Genesys requires HTTPS for embedded apps

2. **CORS Configuration**
   - Only allow `https://apps.usw2.pure.cloud`
   - Don't use wildcard `*`

3. **Data Table Access**
   - App uses logged-in user's permissions
   - No credentials stored in app
   - OAuth handled by Genesys Client SDK

4. **Input Validation**
   - App validates integration and queue selection
   - Preserves all data table fields
   - No direct user input to API

---

## Maintenance

### Regular Tasks:

**Monthly:**
- Review app usage logs
- Check for Genesys SDK updates
- Verify all integrations still in `INTEGRATIONS` object

**When Adding New Integration:**
1. Update `INTEGRATIONS` object in `index.html`
2. Add new integration ID and metadata
3. Redeploy app
4. Test with new integration

**When Removing Integration:**
1. Remove from `INTEGRATIONS` object
2. Redeploy app

---

## Support

### For App Issues:
- Check browser console (F12) for errors
- Verify hosting is accessible
- Test OAuth permissions

### For Queue Switching Issues:
- See main Queue Switching Guide
- Contact GSD Genesys Team

---

## Quick Reference

**App Files:**
- `index.html` - Main app (single file)

**Hosting URLs:**
- S3: `s3://gsd-facebook-queue-switcher/index.html`
- CloudFront: `https://YOUR-DIST.cloudfront.net`
- GitHub: `https://YOUR-ORG.github.io/facebook-queue-switcher/`

**Genesys Configuration:**
- Admin → Integrations → Custom Client Application
- Application Type: `widget`
- iframe Sandbox: `allow-scripts allow-same-origin allow-forms`

**Required Permissions:**
- routing:queue:view
- architect:datatable:view
- architect:datatable:edit

---

**Last Updated:** December 9, 2025
**App Version:** 1.0
