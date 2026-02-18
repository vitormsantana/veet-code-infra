variable "rest_api_id" {}
variable "parent_id" {}
variable "lambda_name" {}
variable "lambda_invoke_arn" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_resource" "frontend_event_reciever" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = "frontend_event_reciever"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.frontend_event_reciever.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.frontend_event_reciever.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn

  depends_on = [aws_lambda_permission.api_gateway]
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.frontend_event_reciever.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.frontend_event_reciever.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 204}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.frontend_event_reciever.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "204"

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
  resource_id = aws_api_gateway_resource.frontend_event_reciever.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "204"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,x-correlation-id,x-env,x-app-version'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeFrontendEventReciever"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/*/*/frontend_event_reciever"
}

output "deployment_trigger" {
  value = sha1(jsonencode({
    resource     = aws_api_gateway_resource.frontend_event_reciever.id
    methods      = [aws_api_gateway_method.post.id, aws_api_gateway_method.options.id]
    integrations = [aws_api_gateway_integration.post.id, aws_api_gateway_integration.options.id]
    responses = [
      aws_api_gateway_method_response.options.id,
      aws_api_gateway_integration_response.options.id,
    ]
    permission = aws_lambda_permission.api_gateway.id
  }))
}
