output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool used for authentication."
  value       = aws_cognito_user_pool.veet_code_user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "Client ID for the front-end application registered in Cognito."
  value       = aws_cognito_user_pool_client.veet_code_app_client.id
}

output "cognito_user_pool_endpoint" {
  description = "Endpoint URL for the Cognito user pool; useful for constructing login URLs."
  value       = aws_cognito_user_pool.veet_code_user_pool.endpoint
}

output "cognito_identity_pool_id" {
  description = "ID of the Cognito identity pool configured for this project."
  value       = aws_cognito_identity_pool.veet_code_identity_pool.id
}

output "cognito_user_pool_domain" {
  description = "Hosted UI domain for the Cognito user pool."
  value = format(
    "https://%s.auth.%s.amazoncognito.com",
    aws_cognito_user_pool_domain.veet_code_user_pool_domain.domain,
    data.aws_region.current.name
  )
}

output "frontend_event_reciever_events_bucket" {
  description = "S3 bucket used to persist frontend analytics events."
  value       = aws_s3_bucket.frontend_events.bucket
}

output "frontend_event_reciever_endpoint" {
  description = "API Gateway endpoint for frontend_event_reciever ingestion."
  value = format(
    "https://%s.execute-api.%s.amazonaws.com/%s/frontend_event_reciever",
    aws_api_gateway_rest_api.hammocker_api.id,
    data.aws_region.current.name,
    aws_api_gateway_stage.dev.stage_name
  )
}
