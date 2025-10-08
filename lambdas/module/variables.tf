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

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 25
}
