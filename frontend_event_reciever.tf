resource "aws_s3_bucket" "frontend_events" {
  bucket = "veet-code-frontend-events-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "frontend_events" {
  bucket                  = aws_s3_bucket.frontend_events.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend_events" {
  bucket = aws_s3_bucket.frontend_events.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "lambda_frontend_event_reciever" {
  source          = "./lambdas/module"
  lambda_name     = "frontend_event_reciever"
  zip_file        = "${path.module}/lambdas/frontend_event_reciever/frontend_event_reciever.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  timeout     = var.frontend_event_reciever_lambda_timeout
  memory_size = var.frontend_event_reciever_lambda_memory_size

  env_vars = {
    events_bucket_name = aws_s3_bucket.frontend_events.bucket
    EVENTS_BUCKET      = aws_s3_bucket.frontend_events.bucket
    EVENTS_PREFIX      = var.frontend_event_reciever_events_prefix
    ALLOWED_ORIGINS    = var.frontend_event_reciever_allowed_origins
    REQUIRE_AUTH       = var.frontend_event_reciever_require_auth
    METRICS_NAMESPACE  = var.frontend_event_reciever_metrics_namespace
  }
}

module "frontend_event_reciever_integration" {
  source            = "./apigateway_integrations/frontend_event_reciever"
  rest_api_id       = aws_api_gateway_rest_api.hammocker_api.id
  parent_id         = aws_api_gateway_rest_api.hammocker_api.root_resource_id
  lambda_name       = module.lambda_frontend_event_reciever.lambda_function_name
  lambda_invoke_arn = module.lambda_frontend_event_reciever.lambda_invoke_arn
}
