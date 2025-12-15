# Tarot Card Shuffle Draw - React Frontend Infrastructure

This directory contains the Terraform configuration for deploying the React frontend to AWS using S3, CloudFront, and ACM.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform or OpenTofu >= 1.0
- A Route53 hosted zone for your domain
- An S3 bucket for Terraform state

## Setup

1. **Create terraform.tfvars file**

   Copy the example file and customize it:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Update the values:
   - `domain_name`: Your desired subdomain (e.g., `tarot-dev.joshuakite.co.uk`)
   - `parent_zone_name`: Your Route53 hosted zone (e.g., `joshuakite.co.uk`)
   - `tfstate_bucket`: Your S3 bucket for Terraform state
   - `tfstate_key`: Unique path for this project's state file

2. **Build the React frontend**

   From the project root:
   ```bash
   cd frontend
   npm run build
   cd ..
   ```

3. **Deploy the infrastructure**

   ```bash
   cd terraform-frontend
   terraform init
   terraform plan
   terraform apply
   ```

4. **Upload the frontend build**

   After deployment, upload the React build to S3:
   ```bash
   BUCKET_NAME=$(terraform output -raw s3_bucket_id)
   aws s3 sync ../frontend/dist s3://$BUCKET_NAME/ --delete
   ```

5. **Invalidate CloudFront cache**

   ```bash
   DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
   aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
   ```

## Infrastructure Components

This configuration uses the [static-website-s3-cloudfront-acm](https://registry.terraform.io/modules/joshuamkite/static-website-s3-cloudfront-acm/aws) module which creates:

- **S3 Bucket**: Hosts the React application build artifacts
- **CloudFront Distribution**: CDN for global content delivery
- **ACM Certificate**: SSL/TLS certificate for HTTPS
- **Route53 Records**: DNS configuration for your custom domain
- **Custom Error Responses**: SPA routing support (404/403 → index.html)

## Integration with Backend API

The React frontend communicates with the Lambda backend API. Set the API URL:

1. Create `frontend/.env` file:
   ```
   VITE_API_URL=https://your-api-gateway-url.execute-api.region.amazonaws.com
   ```

2. Get the API Gateway URL from the main infrastructure:
   ```bash
   cd ..
   terraform output options_landing_page_url
   ```

## Deployment Workflow

For subsequent deployments:

```bash
# Build frontend
cd frontend && npm run build && cd ..

# Upload to S3
cd terraform-frontend
BUCKET_NAME=$(terraform output -raw s3_bucket_id)
aws s3 sync ../frontend/dist s3://$BUCKET_NAME/ --delete

# Invalidate cache
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

## Outputs

After deployment, Terraform provides:

- `website_url`: Your custom domain URL
- `cloudfront_domain_name`: CloudFront distribution domain
- `cloudfront_distribution_id`: For cache invalidations
- `s3_bucket_id`: S3 bucket name

## Clean Up

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: Ensure the S3 bucket is empty before destroying, or the destroy will fail.