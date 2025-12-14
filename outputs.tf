output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
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

output "images_bucket_arn" {
  description = "S3 Bucket ARN for Tarot Images"
  value       = aws_s3_bucket.tarot_images.arn
}

# S3 Bucket Outputs
output "images_bucket_name" {
  description = "S3 Bucket name for Tarot Images"
  value       = aws_s3_bucket.tarot_images.id
}

# Lambda Function Outputs
output "lambda_function_names" {
  description = "Map of Lambda function names"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_function_name
  }
}
