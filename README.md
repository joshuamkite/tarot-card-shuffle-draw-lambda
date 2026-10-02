# Tarot Card Shuffle Draw Lambda

Tarot Card Shuffle Draw is a free and open-source project that shuffles and returns a selection of Tarot cards. Users can choose different decks, specify the number of cards to draw, and include reversed cards in the draw. Public domain illustrations of the cards are presented with the results. 

This port of the application is deployed as a React static website frontend and serverless Go backend using AWS CloudFront, Lambda, and API Gateway. There are other ports available - see [Alternative Deployment Ports](#alternative-deployment-ports) below.

![React](https://img.shields.io/badge/React-19-61DAFB?style=flat&logo=react&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-8-646CFF?style=flat&logo=vite&logoColor=white)
![Bun](https://img.shields.io/badge/Bun-1.4-000000?style=flat&logo=bun&logoColor=white)
![Biome](https://img.shields.io/badge/Biome-2-60A5FA?style=flat&logo=biome&logoColor=white)
![Go](https://img.shields.io/badge/Go-1.26-00ADD8?style=flat&logo=go&logoColor=white)
![OpenTofu](https://img.shields.io/badge/OpenTofu-1.13+-FFDA18?style=flat&logo=opentofu&logoColor=black)
![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=flat&logo=awslambda&logoColor=white)
![CloudFront](https://img.shields.io/badge/AWS-CloudFront-8C4FFF?style=flat&logo=amazoncloudfront&logoColor=white)

- [Tarot Card Shuffle Draw Lambda](#tarot-card-shuffle-draw-lambda)
  - [Features](#features)
  - [Architecture](#architecture)
    - [Components](#components)
  - [Local Development](#local-development)
    - [Frontend](#frontend)
    - [Backend](#backend)
  - [Deploying to AWS](#deploying-to-aws)
    - [Prerequisites](#prerequisites)
    - [Configure](#configure)
    - [Deploy](#deploy)
    - [What the deployment does](#what-the-deployment-does)
    - [Verify](#verify)
    - [Redeploying after changes](#redeploying-after-changes)
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
- **Responsive UI**: Dark/Light theme (follows system preference) with mobile-friendly design
- **Serverless**: Auto-scaling Lambda backend with API Gateway

## Architecture

- **Frontend**: React SPA (Vite) → S3 + CloudFront with custom domain/SSL
- **Backend**: Single Go Lambda function → API Gateway v2 (HTTP API)
- **Assets**: Tarot card images → S3 + CloudFront CDN
- **Infrastructure**: OpenTofu (Terraform-compatible) unified configuration

### Components

**Frontend** ([`frontend/`](frontend/))
- React + Vite build toolchain (single page, no router)
- Dark/Light theme follows the operating system preference (via Context API)
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

`numCards` defaults to 8 if omitted or below 1, and is capped at the size of the chosen deck. An unrecognised `deckSize` or `deckReverse` returns an error.

## Local Development

### Frontend

Requires [Bun](https://bun.sh) 1.4+.

```bash
cd frontend
bun install
bun run dev
```

No environment variables are needed: Vite proxies `/draw` to the production API, which avoids CORS issues (see `frontend/vite.config.js`). To use a different backend, edit the proxy target in `vite.config.js`.

Other useful commands:

```bash
bun run check    # Biome lint + format check
bun run format   # Format with Biome
bun run lint     # Lint only
VITE_API_URL=<your-api-url> bun run build   # Production build into dist/
bun run preview  # Serve the production build locally
```

`VITE_API_URL` is only read by production builds (the app calls `<VITE_API_URL>/draw`). A preview of a build only works if the API's CORS configuration allows the local preview origin, which by default it does not: API Gateway allows only the frontend domain.

### Backend

Requires [Go](https://go.dev) (version in `draw/go.mod`).

```bash
cd draw
go test -v
```

## Deploying to AWS

A single OpenTofu apply deploys everything: the Go Lambda, API Gateway with a custom domain, the card images bucket behind CloudFront, and the frontend (S3 + CloudFront with a custom domain and ACM certificate). The default region is `eu-west-2`; CloudFront certificates are created in `us-east-1` automatically.

### Prerequisites

- [OpenTofu](https://opentofu.org) 1.13+
- AWS credentials with permission to create the resources listed in [Resources](#resources)
- [Bun](https://bun.sh) 1.4+: OpenTofu runs the frontend build during apply
- [Go](https://go.dev) and `make`: the Lambda (linux/arm64, `provided.al2023`) is built during apply
- [AWS CLI](https://aws.amazon.com/cli/): used during apply to sync the frontend to S3 and invalidate CloudFront
- A Route 53 hosted zone for the backend domain, and one for the frontend domain (a subdomain is fine, see `frontend_parent_zone_name`)
- An existing S3 bucket for remote OpenTofu state

### Configure

Edit `terraform/terraform.tfvars`:

| Variable | Purpose |
|----------|---------|
| `aws_region`, `environment`, `project_name` | Region and naming |
| `domain_name`, `hosted_zone_name` | Backend API domain and its hosted zone |
| `frontend_domain_name`, `frontend_parent_zone_name` | Frontend domain and the hosted zone it lives in |
| `backend_bucket`, `backend_key`, `backend_region` | Remote state location |

See [Inputs](#inputs) for all variables and defaults.

### Deploy

```bash
cd terraform
tofu init
tofu plan
tofu apply
```

### What the deployment does

1. Builds the Go Lambda and deploys it behind API Gateway (`POST /draw`), with CORS restricted to the frontend domain.
2. Uploads the card images from the committed `assets/images/` directory to the images bucket, served via CloudFront. The Lambda is given this distribution's URL (`CLOUDFRONT_URL`) and returns image URLs prefixed with it.
3. Builds the frontend with `VITE_API_URL=https://<domain_name>`, syncs `frontend/dist` to the frontend bucket (HTML uncached, other assets immutable), and invalidates the frontend CloudFront cache.

### Verify

```bash
curl -X POST https://<domain_name>/draw \
  -H "Content-Type: application/json" \
  -d '{"deckSize":"Major Arcana only","deckReverse":"Upright only","numCards":3}'
```

Then open `https://<frontend_domain_name>` in a browser. See [API Testing](#api-testing) for the helper scripts.

### Redeploying after changes

Re-run `tofu apply`. Changes under `frontend/src` trigger a rebuild, re-sync and invalidation; changes under `draw/` rebuild the Lambda.

## Developer Tooling

Scripts in [`dev_tooling/`](dev_tooling/):

### API Testing

```bash
# Test API endpoint with CORS headers
./dev_tooling/test_scripts/test_api_connection.sh

# Check API Gateway v2 configuration (set API_ID)
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

Go utility to download Rider-Waite tarot card images from the Wikipedia [Rider–Waite Tarot](https://en.wikipedia.org/wiki/Rider%E2%80%93Waite_Tarot) page. Images are saved to `draw/static/images`; move the ones you want to `assets/images/` for deployment.

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.67.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.67.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.2 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | >= 6.1 |
| <a name="module_frontend_website"></a> [frontend\_website](#module\_frontend\_website) | registry.terraform.io/joshuamkite/static-website-s3-cloudfront-acm/aws | 2.4.0 |
| <a name="module_lambda_functions"></a> [lambda\_functions](#module\_lambda\_functions) | terraform-aws-modules/lambda/aws | ~> 8.9 |

## Resources

| Name | Type |
| ---- | ---- |
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
| [null_resource.build_frontend](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.invalidate_cloudfront](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.sync_frontend_to_s3](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
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
| ---- | ----------- |
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
