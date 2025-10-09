variable "rest_api_id" {}
variable "parent_id" {}
variable "authorizer_id" {}
variable "lambda_name" {}
variable "lambda_invoke_arn" {}

resource "aws_api_gateway_resource" "read_statistics_from_exercises" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = "read_statistics_from_exercises"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn

  depends_on = [aws_lambda_permission.api_gateway]
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn

  depends_on = [aws_lambda_permission.api_gateway]
}

resource "aws_api_gateway_method" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method = "OPTIONS"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.read_statistics_from_exercises.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeReadStatisticsFromExercises"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:sa-east-1:149536475122:${var.rest_api_id}/*/*/read_statistics_from_exercises"
}

output "deployment_trigger" {
  value = sha1(jsonencode({
    resource     = aws_api_gateway_resource.read_statistics_from_exercises.id
    methods      = [
      aws_api_gateway_method.get.id,
      aws_api_gateway_method.post.id,
      aws_api_gateway_method.options.id,
    ]
    integrations = [
      aws_api_gateway_integration.get.id,
      aws_api_gateway_integration.post.id,
      aws_api_gateway_integration.options.id,
    ]
    responses    = [
      aws_api_gateway_method_response.options.id,
      aws_api_gateway_integration_response.options.id,
    ]
    permission   = aws_lambda_permission.api_gateway.id
  }))
}
