# Facebook Queue Switcher - Genesys Embedded App

**A user-friendly web app for GSD team members to switch Facebook Messenger integration queues directly in Genesys Cloud.**

---

## Features

✅ **Simple Interface** - Dropdown menus, no command line needed
✅ **Shows Current Config** - See current queue before switching
✅ **Instant Updates** - Changes take effect immediately
✅ **Secure** - Uses Genesys Cloud OAuth authentication
✅ **Data Safe** - Preserves all integration fields
✅ **Quick Access** - Embedded directly in Genesys UI

---

## Quick Start

### 1. Deploy the App

Choose one deployment method:

**Option A: AWS S3 + CloudFront** (Recommended)
```bash
chmod +x deploy-to-s3.sh
./deploy-to-s3.sh
```

**Option B: GitHub Pages**
- Push `index.html` to GitHub repository
- Enable GitHub Pages in repository settings
- Use the GitHub Pages URL

**Option C: Internal Web Server**
- Copy `index.html` to HTTPS-enabled web server
- Configure CORS headers

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

---

### 2. Configure in Genesys Cloud

1. Go to **Admin → Integrations**
2. Click **Install → Custom Client Application**
3. Configure:
   - **Name:** Facebook Queue Switcher
   - **Application URL:** Your deployed app URL
   - **Application Type:** `widget`
   - **iframe Sandbox:** `allow-scripts allow-same-origin allow-forms`
4. **Activate** the integration

---

### 3. Access the App

Users can access via:
- **Apps Menu** → Facebook Queue Switcher
- **Pin to Toolbar** for quick access

---

## How to Use

1. **Select Integration** (Asia North, Asia, Philippines, North America)
2. **Select Target Queue** (from dropdown)
3. **Click "Switch Queue"**

Done! The change takes effect immediately.

---

## Files

- `index.html` - Main application (single file, all-in-one)
- `DEPLOYMENT.md` - Complete deployment guide
- `deploy-to-s3.sh` - AWS deployment script
- `README.md` - This file

---

## Requirements

**For Deployment:**
- Web hosting with HTTPS
- CORS configured to allow `https://apps.usw2.pure.cloud`

**For Users:**
- Genesys Cloud access
- Permissions: routing:queue:view, architect:datatable:view, architect:datatable:edit

---

## Architecture

**Technology:**
- Pure HTML/CSS/JavaScript (no build step)
- Genesys Cloud Platform Client SDK
- OAuth authentication via Genesys

**How It Works:**
1. App loads in Genesys iframe
2. User authenticates via Genesys OAuth
3. App fetches queues via Genesys API
4. User selects integration + queue
5. App updates data table via Genesys API
6. Change takes effect immediately

---

## Benefits vs Command Line

| Feature | Command Line | Embedded App |
|---------|-------------|--------------|
| **Ease of Use** | Requires technical knowledge | Simple dropdown interface |
| **Access** | Terminal required | Built into Genesys UI |
| **Authentication** | Environment variables | Automatic via Genesys OAuth |
| **Queue Lookup** | Manual queue ID lookup | Automatic dropdown |
| **Error Prevention** | Typos possible | Validated selections |
| **Training Required** | Yes | Minimal |

---

## Security

- ✅ HTTPS only
- ✅ Genesys OAuth authentication
- ✅ No credentials in code
- ✅ User-level permissions enforced
- ✅ CORS restricted to Genesys domain

---

## Maintenance

### Adding New Integration

1. Edit `index.html`
2. Add to `INTEGRATIONS` object:
```javascript
'new-integration-id': {
    name: 'Integration Name',
    platform: 'facebook',
    area_name: 'Area',
    department: 'LMS',
    integration_name: 'FB: Integration Name',
    facebook_page_id: 'page-id',
    active: true
}
```
3. Add dropdown option in HTML
4. Redeploy

### Updating the App

1. Edit `index.html`
2. Redeploy (see deployment method)
3. Invalidate cache if using CloudFront

---

## Troubleshooting

See [DEPLOYMENT.md](DEPLOYMENT.md) for comprehensive troubleshooting guide.

**Common Issues:**
- **Blank screen:** Check HTTPS and CORS configuration
- **Can't load queues:** Verify user permissions
- **Switch fails:** Check data table permissions

---

## Support

**For Technical Issues:**
- Check browser console (F12)
- See DEPLOYMENT.md troubleshooting section
- Contact GSD Genesys Team

**For Queue Routing Issues:**
- See Facebook_Queue_Switching_Guide.md
- Contact GSD Operations

---

## Related Documentation

- **DEPLOYMENT.md** - Complete deployment instructions
- **Facebook_Queue_Switching_Guide.md** - Command line version guide
- **Facebook_Dynamic_Routing_Operations_Guide.md** - Overall routing documentation

---

## Version History

**v1.0** (December 9, 2025)
- Initial release
- Support for 4 Facebook integrations
- Automatic queue lookup
- Current configuration display
- Field preservation on updates

---

**Created:** December 9, 2025
**Location:** `C:\Users\madskilz80\dev\gsd-messenger-services\apps\facebook-queue-switcher\`
**Deployed URL:** (To be configured)
