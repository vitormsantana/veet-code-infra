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
