# API Gateway HTTP API
resource "aws_apigatewayv2_api" "tarot_api" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "Tarot Card Shuffle Draw HTTP API"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["*"]
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.tarot_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
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

  default_route_settings {
    throttling_rate_limit  = var.default_throttling_rate_limit
    throttling_burst_limit = var.default_throttling_burst_limit
  }
}

# API Gateway Integrations
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each               = module.lambda_functions
  api_id                 = aws_apigatewayv2_api.tarot_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_function_invoke_arn
  payload_format_version = "2.0"
}

# Local mapping for routes to Lambda functions
locals {
  api_routes = {
    options_page = {
      route_key  = "GET /"
      lambda_key = "options-page"
    }
    draw_function = {
      route_key  = "POST /draw"
      lambda_key = "draw"
    }
    license_page = {
      route_key  = "GET /license"
      lambda_key = "license"
    }
  }
}

# API Gateway Routes
resource "aws_apigatewayv2_route" "api_routes" {
  for_each  = local.api_routes
  api_id    = aws_apigatewayv2_api.tarot_api.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.value.lambda_key].id}"
}
