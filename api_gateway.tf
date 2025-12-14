module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = ">= 6.0"

  name          = "${local.name_prefix}-api"
  description   = "Tarot Card Shuffle Draw HTTP API"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_credentials = false
    allow_headers     = ["content-type", "authorization"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_origins     = ["*"]
    expose_headers    = ["date"]
    max_age           = 86400
  }

  # Create API only - routes and integrations will be separate resources
  create_routes_and_integrations = false

  # Access logging
  stage_access_log_settings = {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      userAgent      = "$context.identity.userAgent"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  # Throttling settings
  stage_default_route_settings = {
    throttling_burst_limit = var.default_throttling_burst_limit
    throttling_rate_limit  = var.default_throttling_rate_limit
  }

  hosted_zone_name = var.hosted_zone_name
  domain_name      = var.domain_name

}

# API Gateway Integrations
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each               = module.lambda_functions
  api_id                 = module.api_gateway.api_id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "${each.key} Lambda integration"
  integration_method     = "POST"
  integration_uri        = each.value.lambda_function_invoke_arn
  payload_format_version = "2.0"
}

# Local mapping for routes to Lambda functions
locals {
  api_routes = {
    options_page = {
      route_key  = "GET /"
      lambda_key = "options"
    }
    draw_function = {
      route_key  = "POST /draw"
      lambda_key = "draw"
    }
    license_page = {
      route_key  = "GET /license"
      lambda_key = "license-page"
    }
  }
}

# API Gateway Routes
resource "aws_apigatewayv2_route" "api_routes" {
  for_each  = local.api_routes
  api_id    = module.api_gateway.api_id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.value.lambda_key].id}"
}
