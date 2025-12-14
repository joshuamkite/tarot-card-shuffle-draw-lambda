# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${local.name_prefix}-*:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.name_prefix}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Functions using terraform-aws-modules/lambda
module "lambda_functions" {
  for_each = toset([
    "options",
    "draw",
    "license-page"
  ])

  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.1"

  function_name = "${local.name_prefix}-${each.key}"
  handler       = "bootstrap"
  runtime       = "provided.al2023"

  source_path = [{
    path = "${path.module}/${each.key}"
    commands = [
      "make",
      ":zip"
    ]
  }]

  architectures = ["arm64"]
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment_variables = {
    CLOUDFRONT_URL = "https://${aws_cloudfront_distribution.tarot_distribution.domain_name}"
  }

  create_role                       = false
  lambda_role                       = aws_iam_role.lambda_role.arn
  cloudwatch_logs_retention_in_days = var.log_retention_days
  include_default_tag               = false
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each      = module.lambda_functions
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}
