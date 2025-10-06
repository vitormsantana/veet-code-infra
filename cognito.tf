locals {
  google_client_id_trimmed     = trimspace(var.google_client_id)
  google_client_secret_trimmed = trimspace(var.google_client_secret)
  enable_google_identity_provider = (
    length(local.google_client_id_trimmed) > 0 &&
    length(local.google_client_secret_trimmed) > 0
  )
  supported_identity_providers = local.enable_google_identity_provider ? ["COGNITO", "Google"] : ["COGNITO"]
}

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

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = local.supported_identity_providers

  callback_urls = [
    "http://localhost:4200/login"
  ]

  logout_urls = [
    "http://localhost:4200"
  ]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  depends_on = [aws_cognito_identity_provider.google]
}

resource "aws_cognito_identity_pool" "veet_code_identity_pool" {
  identity_pool_name               = "veet-code-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.veet_code_app_client.id
    provider_name = aws_cognito_user_pool.veet_code_user_pool.endpoint
  }
}

resource "aws_cognito_user_pool_domain" "veet_code_user_pool_domain" {
  domain       = "hammocker-domain"
  user_pool_id = aws_cognito_user_pool.veet_code_user_pool.id
}

resource "aws_cognito_identity_provider" "google" {
  count         = local.enable_google_identity_provider ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.veet_code_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email openid profile"
  }

  attribute_mapping = {
    email = "email"
  }
}
