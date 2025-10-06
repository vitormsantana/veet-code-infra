resource "aws_api_gateway_rest_api" "hammocker_api" {
  name        = "hammocker-api"
  description = "hammocker REST API"
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name            = "hammocker-cognito-auth"
  rest_api_id     = aws_api_gateway_rest_api.hammocker_api.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.veet_code_user_pool.arn]
}

resource "aws_api_gateway_deployment" "deployment" {
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    module.create_exercise_integration,
    module.read_exercises_integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.hammocker_api.id
}


resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.hammocker_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.hammocker_api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'"
  }
}

resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.hammocker_api.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'"
  }
}

resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.hammocker_api.id
  response_type = "UNAUTHORIZED"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'"
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = aws_api_gateway_rest_api.hammocker_api.id
  response_type = "ACCESS_DENIED"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'"
  }
}

module "create_exercise_integration" {
  source            = "./apigateway_integrations/create_exercise"
  rest_api_id       = aws_api_gateway_rest_api.hammocker_api.id
  parent_id         = aws_api_gateway_rest_api.hammocker_api.root_resource_id
  authorizer_id     = aws_api_gateway_authorizer.cognito_auth.id
  lambda_name       = module.lambda_add_questions_to_dynamo.lambda_function_name
  lambda_invoke_arn = module.lambda_add_questions_to_dynamo.lambda_invoke_arn
}

module "read_exercises_integration" {
  source            = "./apigateway_integrations/read_exercises"
  rest_api_id       = aws_api_gateway_rest_api.hammocker_api.id
  parent_id         = aws_api_gateway_rest_api.hammocker_api.root_resource_id
  authorizer_id     = aws_api_gateway_authorizer.cognito_auth.id
  lambda_name       = module.lambda_read_exercises_from_dynamo.lambda_function_name
  lambda_invoke_arn = module.lambda_read_exercises_from_dynamo.lambda_invoke_arn
}
