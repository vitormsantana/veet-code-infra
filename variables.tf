variable "google_client_id" {
  description = "Google OAuth client ID used for the Cognito identity provider."
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google OAuth client secret used for the Cognito identity provider."
  type        = string
  default     = ""
  sensitive   = true
}

variable "openai_api_key" {
  description = "API key used by the OpenAI powered recommendation lambda."
  type        = string
  default     = ""
  sensitive   = true
}
