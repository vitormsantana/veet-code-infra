resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
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
  function_name    = var.lambda_name
  role             = var.lambda_role_arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = var.zip_file
  source_code_hash = filebase64sha256(var.zip_file)

  environment {
    variables = var.env_vars
  }
}
