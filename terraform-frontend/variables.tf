variable "domain_name" {
  description = "Domain name for the static website"
  type        = string
}

variable "parent_zone_name" {
  description = "Parent hosted zone name (for subdomains). If not set, uses domain_name"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region for S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "backend_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "backend_key" {
  description = "S3 key for Terraform state"
  type        = string
}

variable "backend_region" {
  description = "AWS region for Terraform state bucket"
  type        = string
}

variable "cloudfront_custom_error_responses" {
  description = "Custom error responses for CloudFront (required for SPA routing)"
  type        = list(any)
}
