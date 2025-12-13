variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tarot"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "tarot-card-shuffle"
    ManagedBy = "opentofu"
  }
}

variable "origin_access_control_name" {
  description = "Name for the CloudFront Origin Access Control"
  type        = string
  default     = "TarotImages"
}

variable "default_throttling_rate_limit" {
  description = "Default API Gateway throttling rate limit"
  type        = number
  default     = 100
}

variable "default_throttling_burst_limit" {
  description = "Default API Gateway throttling burst limit"
  type        = number
  default     = 200
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
