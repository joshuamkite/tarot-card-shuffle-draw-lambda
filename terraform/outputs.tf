output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.tarot_distribution.id
}

output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.tarot_distribution.domain_name}/"
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.tarot_distribution.domain_name
}

output "images_bucket_arn" {
  description = "S3 Bucket ARN for Tarot Images"
  value       = aws_s3_bucket.tarot_images.arn
}

output "images_bucket_name" {
  description = "S3 Bucket name for Tarot Images"
  value       = aws_s3_bucket.tarot_images.id
}

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_function_name
  }
}

output "options_landing_page_url" {
  description = "URL for the options landing page (frontend)"
  value       = "https://${var.frontend_domain_name}/"
}

output "api_gateway_invoke_url" {
  description = "The invocation URL for the API Gateway"
  value       = module.api_gateway.api_endpoint
}

# Frontend Outputs
output "frontend_website_url" {
  description = "Frontend website URL"
  value       = "https://${var.frontend_domain_name}"
}

output "frontend_cloudfront_domain_name" {
  description = "Frontend CloudFront distribution domain name"
  value       = module.frontend_website.cloudfront_domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "Frontend CloudFront distribution ID (for cache invalidation)"
  value       = module.frontend_website.cloudfront_distribution_id
}

output "frontend_s3_bucket_id" {
  description = "Frontend S3 bucket ID (name)"
  value       = module.frontend_website.s3_bucket_id
}

output "frontend_acm_certificate_id" {
  description = "Frontend ACM certificate ID"
  value       = module.frontend_website.acm_certificate_id
}

