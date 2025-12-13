# Tarot Card Shuffle Draw - OpenTofu/Terraform Deployment

Serverless tarot card reading application deployed on AWS using OpenTofu/Terraform.

## Architecture

- **API Gateway HTTP API** - RESTful endpoints for card drawing
- **Lambda Functions** (Go) - Three functions for options page, draw logic, and license page
- **S3 + CloudFront** - Static image hosting with CDN distribution
- **CloudWatch** - Logging for all Lambda functions and API Gateway

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.6.0 or [Terraform](https://www.terraform.io/) >= 1.6.0
- AWS CLI configured with appropriate credentials
- Go 1.21+ (for building Lambda functions)
- Make

## Project Structure

```
.
├── versions.tf              # Terraform/provider version requirements
├── main.tf                  # Data sources and locals
├── variables.tf             # Input variables
├── lambda.tf                # Lambda functions using terraform-aws-modules/lambda
├── api_gateway.tf           # API Gateway HTTP API
├── s3.tf                    # S3 bucket for images
├── cloudfront.tf            # CloudFront distribution
├── cloudwatch.tf            # CloudWatch log groups
├── outputs.tf               # Output values
└── terraform.tfvars.example # Example configuration
```

## Quick Start

### 1. Build Lambda Functions

```bash
# The Lambda module will automatically run 'make' in each directory
# Just ensure the makefiles are set up correctly
cd optionsPage && make && cd ..
cd handleDraw && make && cd ..
cd licensePage && make && cd ..
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
environment  = "dev"
project_name = "tarot"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
tofu init

# Review planned changes
tofu plan

# Deploy
tofu apply
```

The `terraform-aws-modules/lambda` module will automatically:
- Build the Go binaries using the `make` command
- Package them into zip files
- Deploy to Lambda

### 4. Upload Images to S3

After deployment, upload tarot card images:

```bash
BUCKET_NAME=$(tofu output -raw images_bucket_name)
aws s3 sync handleDraw/static/images/ s3://$BUCKET_NAME/images/
```

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `project_name` | Project name prefix | `tarot` |
| `environment` | Environment (dev/staging/prod) | `dev` |
| `lambda_timeout` | Lambda timeout in seconds | `10` |
| `lambda_memory_size` | Lambda memory in MB | `128` |
| `log_retention_days` | CloudWatch log retention | `7` |
| `default_throttling_rate_limit` | API rate limit | `100` |
| `default_throttling_burst_limit` | API burst limit | `200` |

## Outputs

After deployment, view outputs:

```bash
tofu output
```

Key outputs:
- `api_url` - API Gateway endpoint URL
- `cloudfront_distribution_url` - CloudFront URL for images
- `images_bucket_name` - S3 bucket name
- `lambda_function_names` - Map of all Lambda function names

## Testing

Test the deployed API:

```bash
# Get the API URL
API_URL=$(tofu output -raw api_url)

# Test options page
curl $API_URL

# Test draw endpoint
curl -X POST $API_URL/draw -H "Content-Type: application/json" -d '{"count": 3}'

# Test license page
curl $API_URL/license
```

## Updating Lambda Functions

After code changes:

```bash
# Rebuild
cd handleDraw && make && cd ..

# Redeploy
tofu apply
```

The Lambda module will detect changes and redeploy automatically.

## Monitoring

View logs:

```bash
# Lambda function logs
aws logs tail /aws/lambda/tarot-dev-draw --follow
aws logs tail /aws/lambda/tarot-dev-options-page --follow
aws logs tail /aws/lambda/tarot-dev-license --follow

# API Gateway logs
aws logs tail /aws/api-gateway/tarot-dev --follow
```

## CloudFront Cache Management

Invalidate CloudFront cache after uploading new images:

```bash
DISTRIBUTION_ID=$(tofu output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

## Cleanup

Remove all resources:

```bash
# Empty S3 bucket first
BUCKET_NAME=$(tofu output -raw images_bucket_name)
aws s3 rm s3://$BUCKET_NAME --recursive

# Destroy infrastructure
tofu destroy
```

## Remote State (Recommended)

For team environments, configure S3 backend in `versions.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "tarot/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Then initialize with backend:

```bash
tofu init \
  -backend-config="bucket=your-backend-bucket" \
  -backend-config="key=tarot/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

## Modules Used

- `terraform-aws-modules/lambda/aws` (~> 8.1) - Lambda function packaging and deployment

## Troubleshooting

### Lambda Function Errors

Check CloudWatch logs for detailed error messages:

```bash
aws logs tail /aws/lambda/tarot-dev-draw --follow
```

### API Gateway 502 Errors

Usually indicates Lambda function errors. Check:
1. Lambda function logs in CloudWatch
2. Lambda function permissions
3. Environment variables are set correctly

### Images Not Loading

Verify:
1. Images uploaded to S3 bucket
2. CloudFront distribution is deployed (can take 15-20 minutes)
3. S3 bucket policy allows CloudFront access

## License

See [LICENSE](LICENSE) file for details.
