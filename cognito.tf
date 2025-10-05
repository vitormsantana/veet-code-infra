resource "aws_cognito_user_pool" "veet_code_user_pool" {
  name = "veet-code-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # Mensagem de boas-vindas
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # MFA opcional
  mfa_configuration = "OFF"

  lifecycle {
    ignore_changes = [
      password_policy[0].temporary_password_validity_days
    ]
  }
}

resource "aws_cognito_user_pool_client" "veet_code_app_client" {
  name         = "veet-code-app-client"
  user_pool_id = aws_cognito_user_pool.veet_code_user_pool.id

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_cognito_identity_pool" "veet_code_identity_pool" {
  identity_pool_name               = "veet-code-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.veet_code_app_client.id
    provider_name = aws_cognito_user_pool.veet_code_user_pool.endpoint
  }
}

