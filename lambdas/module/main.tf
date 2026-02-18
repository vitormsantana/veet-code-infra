resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name     = var.lambda_name
  role              = var.lambda_role_arn
  handler           = var.handler
  runtime           = var.runtime
  filename          = var.deploy_from_s3 ? null : var.zip_file
  s3_bucket         = var.deploy_from_s3 ? var.s3_bucket : null
  s3_key            = var.deploy_from_s3 ? var.s3_key : null
  s3_object_version = var.deploy_from_s3 ? var.s3_object_version : null
  source_code_hash  = var.zip_file != null ? filebase64sha256(var.zip_file) : null
  memory_size       = var.memory_size
  timeout           = var.timeout

  dynamic "environment" {
    for_each = length(var.env_vars) > 0 ? [1] : []
    content {
      variables = var.env_vars
    }
  }

  lifecycle {
    precondition {
      condition     = var.deploy_from_s3 == false || (var.s3_bucket != null && var.s3_key != null)
      error_message = "When deploy_from_s3 is true, s3_bucket and s3_key must be provided."
    }
  }

}
