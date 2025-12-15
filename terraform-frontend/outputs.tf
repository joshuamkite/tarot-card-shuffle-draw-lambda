output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.static-website-s3-cloudfront-acm.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (needed for cache invalidation)"
  value       = module.static-website-s3-cloudfront-acm.cloudfront_distribution_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.static-website-s3-cloudfront-acm.s3_bucket_arn
}

output "s3_bucket_id" {
  description = "S3 bucket ID (name)"
  value       = module.static-website-s3-cloudfront-acm.s3_bucket_id
}

output "acm_certificate_id" {
  description = "ACM certificate ID"
  value       = module.static-website-s3-cloudfront-acm.acm_certificate_id
}

output "website_url" {
  description = "Website URL"
  value       = "https://${var.domain_name}"
}
