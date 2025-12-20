# Tarot Card Shuffle Draw Lambda

Tarot Card Shuffle Draw is a free and open-source project that shuffles and returns a selection of Tarot cards. Users can choose different decks, specify the number of cards to draw, and include reversed cards in the draw. Public domain illustrations of the cards are presented with the results. 

This port of the application is deployed as a React static website frontend and serverless Go backend using AWS CloudFront, Lambda, and API Gateway. There are other ports available - see [Alternative Deployment Ports](#alternative-deployment-ports) below.

- [Tarot Card Shuffle Draw Lambda](#tarot-card-shuffle-draw-lambda)
  - [Features](#features)
  - [Architecture](#architecture)
    - [Components](#components)
  - [Quick Start](#quick-start)
    - [Build and deploy infrastructure (using OpenTofu)](#build-and-deploy-infrastructure-using-opentofu)
    - [Local frontend development](#local-frontend-development)
    - [Test backend locally](#test-backend-locally)
  - [Developer Tooling](#developer-tooling)
    - [API Testing](#api-testing)
    - [CloudFront Cache Management](#cloudfront-cache-management)
    - [Image Downloader](#image-downloader)
  - [Project Structure](#project-structure)
  - [Alternative Deployment Ports](#alternative-deployment-ports)
  - [License](#license)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Features

- **Deck Options**: Full Deck, Major Arcana only, Minor Arcana only.
- **Reversed Cards**: Option to include reversed cards in the draw.
- **Random Draw**: Utilizes high-quality randomness using Go `crypto/rand`.
- **Responsive UI**: Dark/Light theme support with mobile-friendly design
- **Serverless**: Auto-scaling Lambda backend with API Gateway

## Architecture

- **Frontend**: React SPA (Vite) → S3 + CloudFront with custom domain/SSL
- **Backend**: Single Go Lambda function → API Gateway v2 (HTTP API)
- **Assets**: Tarot card images → S3 + CloudFront CDN
- **Infrastructure**: OpenTofu (Terraform-compatible) unified configuration

### Components

**Frontend** ([`frontend/`](frontend/))
- React + Vite build toolchain with hash-based routing
- Dark/Light theme toggle via Context API
- CORS-restricted API communication
- Deployed to CloudFront + S3 with custom domain

**Backend** ([`draw/`](draw/))
- Single Go Lambda function exposing `POST /draw` endpoint
- API Gateway v2 HTTP API with CORS configuration
- Cryptographically secure shuffling via `crypto/rand`

**API Contract**: `POST /draw`
```json
{
  "deckSize": "Full Deck | Major Arcana only | Minor Arcana only",
  "deckReverse": "Upright only | Upright and reversed",
  "numCards": 1-78
}
```

## Quick Start

### Build and deploy infrastructure (using OpenTofu)

In most cases this will be all that is needed. Ensure all variables have values assigned and:

```bash
cd terraform
tofu init
tofu plan
tofu apply
```

### Local frontend development
```bash
cd frontend
npm install
VITE_API_URL=<your-api-url> npm run dev
```

### Test backend locally
```bash
cd draw
go test -v
```

## Developer Tooling

Scripts in [`dev_tooling/`](dev_tooling/):

### API Testing

```bash
# Test API endpoint with CORS headers
./dev_tooling/test_scripts/test_api_connection.sh

# Check API Gateway v2 configuration  
./dev_tooling/test_scripts/check_draw_function.sh
```

**Note**: Update API URLs and domain names in scripts to match your deployment.

### CloudFront Cache Management

Normally this will be handled as part of deployment

```bash
# Invalidate card images cache
DISTRIBUTION_ID=<your-distribution-id> ./dev_tooling/cloudfront-invalidation.sh
```

### Image Downloader

Go utility to download Rider-Waite tarot card images from Wikimedia commons:

```bash
cd dev_tooling/image_downloader
go run main.go
```

See [`dev_tooling/image_downloader/README.md`](dev_tooling/image_downloader/README.md) for details.

## Project Structure

```
.
├── frontend/           # React + Vite frontend application
├── draw/              # Go Lambda function for card drawing
├── terraform/         # Infrastructure as Code (OpenTofu/Terraform)
├── dev_tooling/       # Development and testing utilities
└── assets/images/     # Tarot card images (uploaded to S3)
```

## Alternative Deployment Ports

- **CLI**: Cross-platform command-line tool → [tarot-card-shuffle-draw](https://github.com/joshuamkite/tarot-card-shuffle-draw)
- **Docker/Kubernetes**: Helm chart and container deployment → [tarot-card-shuffle-draw-web](https://github.com/joshuamkite/tarot-card-shuffle-draw-web)

## License

GNU Affero General Public License -See [`LICENSE`](LICENSE) file for details. Tarot card images are public domain.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | >= 6.0 |
| <a name="module_frontend_website"></a> [frontend\_website](#module\_frontend\_website) | registry.terraform.io/joshuamkite/static-website-s3-cloudfront-acm/aws | 2.4.0 |
| <a name="module_lambda_functions"></a> [lambda\_functions](#module\_lambda\_functions) | terraform-aws-modules/lambda/aws | ~> 8.1 |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_integration.lambda_integrations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.api_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_cloudfront_distribution.tarot_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.tarot_images_oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudwatch_log_group.api_gateway_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.tarot_images](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.tarot_images_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.tarot_images](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.card](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.frontend_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.build_frontend](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.invalidate_cloudfront](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for deployment | `string` | `"eu-west-2"` | no |
| <a name="input_backend_bucket"></a> [backend\_bucket](#input\_backend\_bucket) | n/a | `any` | n/a | yes |
| <a name="input_backend_key"></a> [backend\_key](#input\_backend\_key) | n/a | `any` | n/a | yes |
| <a name="input_backend_region"></a> [backend\_region](#input\_backend\_region) | n/a | `any` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | <pre>{<br/>  "ManagedBy": "opentofu",<br/>  "Project": "tarot-card-shuffle"<br/>}</pre> | no |
| <a name="input_default_throttling_burst_limit"></a> [default\_throttling\_burst\_limit](#input\_default\_throttling\_burst\_limit) | Default API Gateway throttling burst limit | `number` | `200` | no |
| <a name="input_default_throttling_rate_limit"></a> [default\_throttling\_rate\_limit](#input\_default\_throttling\_rate\_limit) | Default API Gateway throttling rate limit | `number` | `100` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_frontend_domain_name"></a> [frontend\_domain\_name](#input\_frontend\_domain\_name) | Domain name for the React frontend | `string` | n/a | yes |
| <a name="input_frontend_parent_zone_name"></a> [frontend\_parent\_zone\_name](#input\_frontend\_parent\_zone\_name) | Parent hosted zone name for frontend (for subdomains). If not set, uses frontend\_domain\_name | `string` | `""` | no |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | n/a | `any` | n/a | yes |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout in seconds | `number` | `30` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention in days | `number` | `7` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"tarot"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS Account ID |
| <a name="output_api_gateway_invoke_url"></a> [api\_gateway\_invoke\_url](#output\_api\_gateway\_invoke\_url) | The invocation URL for the API Gateway |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | CloudFront distribution ID |
| <a name="output_cloudfront_distribution_url"></a> [cloudfront\_distribution\_url](#output\_cloudfront\_distribution\_url) | CloudFront distribution URL |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | CloudFront distribution domain name |
| <a name="output_frontend_acm_certificate_id"></a> [frontend\_acm\_certificate\_id](#output\_frontend\_acm\_certificate\_id) | Frontend ACM certificate ID |
| <a name="output_frontend_cloudfront_distribution_id"></a> [frontend\_cloudfront\_distribution\_id](#output\_frontend\_cloudfront\_distribution\_id) | Frontend CloudFront distribution ID (for cache invalidation) |
| <a name="output_frontend_cloudfront_domain_name"></a> [frontend\_cloudfront\_domain\_name](#output\_frontend\_cloudfront\_domain\_name) | Frontend CloudFront distribution domain name |
| <a name="output_frontend_s3_bucket_id"></a> [frontend\_s3\_bucket\_id](#output\_frontend\_s3\_bucket\_id) | Frontend S3 bucket ID (name) |
| <a name="output_frontend_website_url"></a> [frontend\_website\_url](#output\_frontend\_website\_url) | Frontend website URL |
| <a name="output_images_bucket_arn"></a> [images\_bucket\_arn](#output\_images\_bucket\_arn) | S3 Bucket ARN for Tarot Images |
| <a name="output_images_bucket_name"></a> [images\_bucket\_name](#output\_images\_bucket\_name) | S3 Bucket name for Tarot Images |
| <a name="output_lambda_function_names"></a> [lambda\_function\_names](#output\_lambda\_function\_names) | Map of Lambda function names |
<!-- END_TF_DOCS -->
