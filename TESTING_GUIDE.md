# Facebook Queue Switcher - Testing Guide

## Fixes Applied (December 10, 2025)

###  Problem: Queue Dropdown Not Populating
**Root Cause:**
- Client App SDK alone doesn't provide API methods
- Code was calling non-existent methods like `clientApp.routing.getQueues()`

**Solution:**
1. Added Platform Client SDK (v177.0.0)
2. Proper initialization with both SDKs
3. Updated all API calls to use Platform Client API methods

## Testing Options

### Option 1: Local UI Testing (Basic)
Test the interface without Genesys connection:

```bash
# Open in browser
start index.html
```

**What to Check:**
- ✓ Page loads without errors
- ✓ Dropdowns render correctly
- ✓ Buttons are visible
- ✗ Won't connect to Genesys (expected)

### Option 2: Genesys Cloud Integration Testing (Full)
Test with real Genesys Cloud integration:

**Prerequisites:**
- HTTPS URL (CloudFront or other)
- Genesys Cloud admin access

**Steps:**

1. **Get HTTPS URL** (choose one):
   - Use existing CloudFront distribution
   - Create new CloudFront distribution:
     ```bash
     aws cloudfront create-distribution \
       --origin-domain-name gsd-facebook-queue-switcher.s3.us-east-1.amazonaws.com \
       --default-root-object index.html
     ```
   - Use GitHub Pages (push to repo, enable Pages)
   - Use internal HTTPS server

2. **Configure in Genesys Cloud:**
   - Go to: Admin → Integrations
   - Install → Custom Client Application
   - **Name:** Facebook Queue Switcher
   - **Application URL:** `https://YOUR-CLOUDFRONT-DOMAIN/`
   - **Application Type:** `widget`
   - **iframe Sandbox:** `allow-scripts allow-same-origin allow-forms`
   - **Activate** the integration

3. **Access the Widget:**
   - In Genesys: Apps → Facebook Queue Switcher
   - Or pin to toolbar for quick access

4. **Test End-to-End:**
   - [ ] Widget loads in Genesys iframe
   - [ ] No console errors (F12)
   - [ ] "Client App bootstrapped successfully" in console
   - [ ] Queue dropdown populates with queues
   - [ ] Select integration shows current queue
   - [ ] Switch queue button works
   - [ ] Success message appears
   - [ ] Data table updated (verify in Architect)

### Option 3: Quick CloudFront Setup

```bash
# List existing distributions
aws cloudfront list-distributions --query "DistributionList.Items[*].{ID:Id,Domain:DomainName}"

# If you have an existing distribution for testing, update it:
aws cloudfront get-distribution-config --id YOUR-DIST-ID > dist-config.json
# Edit origin to point to gsd-facebook-queue-switcher.s3.us-east-1.amazonaws.com
aws cloudfront update-distribution --id YOUR-DIST-ID --if-match ETAG --distribution-config file://dist-config.json

# Invalidate cache
aws cloudfront create-invalidation --distribution-id YOUR-DIST-ID --paths "/*"
```

## Troubleshooting

### Issue: "Failed to connect to Genesys Cloud"
**Check:**
- Widget loaded in Genesys iframe (not standalone browser)
- Integration is Active in Genesys
- Browser console for specific error

### Issue: "Failed to load queues"
**Check:**
- User has `routing:queue:view` permission
- Platform Client SDK loaded (check Network tab)
- Console shows "Client App bootstrapped successfully"

### Issue: "Failed to switch queue"
**Check:**
- User has `architect:datatable:edit` permission
- Data table ID is correct: `ac77d4e0-f41b-43f9-aee2-7d9e58606d7a`
- Integration ID exists in data table

### Issue: CORS errors in console
**Check:**
- S3 bucket CORS configured for `https://apps.usw2.pure.cloud`
- CloudFront allows same origin

## Expected Console Output (Success)

```
Client App bootstrapped successfully
[RoutingApi] Successfully loaded 47 queues
[Current Config] Queue: Asia North_SM_Line
✓ Successfully switched Asia North to Asia_SM_Line!
```

## Files Changed

- `index.html` - Added Platform Client SDK, fixed API calls
- `TESTING_GUIDE.md` - This file

## Next Steps

1. Choose testing option (recommend Option 2 for full test)
2. Create/use CloudFront distribution
3. Configure in Genesys Cloud
4. Test end-to-end
5. Document any issues found
6. Commit changes when verified working

## S3 Deployment

Widget is deployed to:
- **Bucket:** `s3://gsd-facebook-queue-switcher/`
- **S3 URL:** http://gsd-facebook-queue-switcher.s3-website-us-east-1.amazonaws.com (HTTP only)
- **Needs:** CloudFront for HTTPS

To update after changes:
```bash
aws s3 cp index.html s3://gsd-facebook-queue-switcher/ --content-type "text/html" --cache-control "max-age=300"
```
