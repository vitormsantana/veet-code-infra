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

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "frontend_event_reciever_events_prefix" {
  description = "S3 prefix for frontend analytics events."
  type        = string
  default     = "analytics-events"
}

variable "frontend_event_reciever_allowed_origins" {
  description = "Comma-separated CORS allowlist consumed by frontend_event_reciever Lambda."
  type        = string
  default     = "*"
}

variable "frontend_event_reciever_require_auth" {
  description = "Extension point for future auth validation in frontend_event_reciever Lambda."
  type        = string
  default     = "false"
}

variable "frontend_event_reciever_metrics_namespace" {
  description = "CloudWatch metrics namespace emitted by frontend_event_reciever Lambda."
  type        = string
  default     = "Veet/AnalyticsEvents"
}

variable "frontend_event_reciever_lambda_timeout" {
  description = "Timeout for frontend_event_reciever Lambda in seconds."
  type        = number
  default     = 30
}

variable "frontend_event_reciever_lambda_memory_size" {
  description = "Memory size for frontend_event_reciever Lambda in MB."
  type        = number
  default     = 256
}
