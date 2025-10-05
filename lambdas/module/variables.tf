variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "zip_file" {
  description = "Path to the Lambda zip file"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

variable "lambda_role_arn" {
  type = string
}