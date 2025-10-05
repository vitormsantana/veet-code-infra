variable "rest_api_id" {}
variable "parent_id" {}
variable "authorizer_id" {}
variable "lambda_name" {}
variable "lambda_invoke_arn" {}

resource "aws_api_gateway_resource" "create_exercise" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = "create_exercise"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.create_exercise.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.create_exercise.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn

  depends_on = [aws_lambda_permission.api_gateway]
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.create_exercise.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.create_exercise.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.create_exercise.id
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
  resource_id = aws_api_gateway_resource.create_exercise.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeCreateExercise"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:sa-east-1:149536475122:${var.rest_api_id}/*/*/create_exercise"
}
