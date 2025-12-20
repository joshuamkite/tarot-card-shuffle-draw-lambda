# Frontend Static Website Infrastructure
# This module creates S3, CloudFront, ACM certificate, and Route53 records for the React frontend

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
  }
}

module "frontend_website" {
  source  = "registry.terraform.io/joshuamkite/static-website-s3-cloudfront-acm/aws"
  version = "2.4.0"

  domain_name           = var.frontend_domain_name
  parent_zone_name      = var.frontend_parent_zone_name != "" ? var.frontend_parent_zone_name : var.hosted_zone_name
  s3_bucket_custom_name = "${var.frontend_domain_name}-${var.aws_region}-${local.account_id}"

  cloudfront_custom_error_responses = [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]

  providers = {
    aws.us-east-1 = aws.us-east-1
    aws           = aws
  }
}

# Build and upload frontend
resource "null_resource" "build_frontend" {
  # Rebuild when API URL changes
  triggers = {
    api_url = "https://${var.domain_name}"
    # Also rebuild if frontend source files change
    frontend_hash = sha256(join("", [for f in fileset("${path.module}/../frontend/src", "**") : filesha256("${path.module}/../frontend/src/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../frontend"
    command     = "VITE_API_URL=https://${var.domain_name} npm run build"
  }
}

# Upload frontend build artifacts to S3
resource "aws_s3_object" "frontend_files" {
  for_each = fileset("${path.module}/../frontend/dist", "**")

  bucket       = module.frontend_website.s3_bucket_id
  key          = each.value
  source       = "${path.module}/../frontend/dist/${each.value}"
  etag         = filemd5("${path.module}/../frontend/dist/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")

  depends_on = [null_resource.build_frontend]
}

# Invalidate CloudFront cache after uploading new files
resource "null_resource" "invalidate_cloudfront" {
  triggers = {
    # Invalidate whenever frontend files change
    frontend_hash = sha256(join("", [for f in fileset("${path.module}/../frontend/dist", "**") : filemd5("${path.module}/../frontend/dist/${f}")]))
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${module.frontend_website.cloudfront_distribution_id} --paths '/*'"
  }

  depends_on = [aws_s3_object.frontend_files]
}
