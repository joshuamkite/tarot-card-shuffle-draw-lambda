# API Gateway Outputs
output "api_url" {
  description = "HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.tarot_api.api_endpoint
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.tarot_api.id
}

# S3 Bucket Outputs
output "images_bucket_name" {
  description = "S3 Bucket name for Tarot Images"
  value       = aws_s3_bucket.tarot_images.id
}

output "images_bucket_arn" {
  description = "S3 Bucket ARN for Tarot Images"
  value       = aws_s3_bucket.tarot_images.arn
}

# CloudFront Outputs
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

# Lambda Function Outputs
output "lambda_function_names" {
  description = "Map of Lambda function names"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_function_name
  }
}

# Deployment Information
output "deployment_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
