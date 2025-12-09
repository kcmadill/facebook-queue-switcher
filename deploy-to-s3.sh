#!/bin/bash
# Deploy Facebook Queue Switcher to AWS S3 + CloudFront

# Configuration
BUCKET_NAME="gsd-facebook-queue-switcher"
REGION="us-east-1"
DIST_ID=""  # Will be set after first CloudFront creation

echo "==========================================="
echo "Facebook Queue Switcher - AWS Deployment"
echo "==========================================="
echo ""

# Step 1: Create S3 bucket (if doesn't exist)
echo "[1/5] Creating S3 bucket..."
if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${BUCKET_NAME}" --region ${REGION}
    echo "  ✓ Bucket created"
else
    echo "  ✓ Bucket already exists"
fi
echo ""

# Step 2: Configure bucket for website hosting
echo "[2/5] Configuring static website hosting..."
aws s3 website "s3://${BUCKET_NAME}" --index-document index.html
echo "  ✓ Website hosting enabled"
echo ""

# Step 3: Set bucket policy for CloudFront access
echo "[3/5] Setting bucket policy..."
cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
  --bucket ${BUCKET_NAME} \
  --policy file:///tmp/bucket-policy.json
echo "  ✓ Bucket policy set"
echo ""

# Step 4: Configure CORS
echo "[4/5] Configuring CORS..."
cat > /tmp/cors.json <<EOF
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
EOF

aws s3api put-bucket-cors \
  --bucket ${BUCKET_NAME} \
  --cors-configuration file:///tmp/cors.json
echo "  ✓ CORS configured"
echo ""

# Step 5: Upload files
echo "[5/5] Uploading files..."
aws s3 cp index.html "s3://${BUCKET_NAME}/" \
  --content-type "text/html" \
  --cache-control "max-age=300" \
  --acl public-read
echo "  ✓ Files uploaded"
echo ""

echo "==========================================="
echo "Deployment Complete!"
echo "==========================================="
echo ""
echo "S3 Website URL:"
echo "http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
echo ""
echo "Next steps:"
echo "1. Create CloudFront distribution (if not done):"
echo "   aws cloudfront create-distribution --origin-domain-name ${BUCKET_NAME}.s3.amazonaws.com --default-root-object index.html"
echo ""
echo "2. Get CloudFront URL and configure in Genesys Cloud"
echo "3. See DEPLOYMENT.md for Genesys configuration steps"
