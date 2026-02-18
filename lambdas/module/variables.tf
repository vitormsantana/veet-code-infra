variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "zip_file" {
  description = "Path to the Lambda zip file"
  type        = string
}

variable "deploy_from_s3" {
  description = "Set to true to deploy code from an S3 object instead of uploading the zip file directly."
  type        = bool
  default     = false
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda artifact when deploy_from_s3 is true."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 object key of the Lambda artifact when deploy_from_s3 is true."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Optional S3 object version for the Lambda artifact."
  type        = string
  default     = null
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

variable "handler" {
  description = "Lambda handler (bootstrap for Go, index.handler for Node)"
  type        = string
  default     = "bootstrap"
}

variable "runtime" {
  description = "Lambda runtime (provided.al2 for Go, nodejs20.x for Node)"
  type        = string
  default     = "provided.al2"
}
