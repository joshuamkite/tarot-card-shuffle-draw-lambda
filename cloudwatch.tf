resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/api-gateway/${local.name_prefix}"
  retention_in_days = var.log_retention_days
}
