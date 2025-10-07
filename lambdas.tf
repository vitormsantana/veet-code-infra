module "lambda_add_questions_to_dynamo" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_add_questions_to_dynamo"
  zip_file        = "${path.module}/lambdas/lambda_add_questions_to_dynamo/lambda_add_questions_to_dynamo.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "veet_code_questions_table"
  }
}

module "lambda_read_exercises_from_dynamo" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_read_exercises_from_dynamo"
  zip_file        = "${path.module}/lambdas/lambda_read_exercises_from_dynamo/lambda_read_exercises_from_dynamo.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "veet_code_questions_table"
  }
}

  module "lambda_read_statistics_from_exercises_table" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_read_statistics_from_exercises_table"
  zip_file        = "${path.module}/lambdas/lambda_read_statistics_from_exercises_table/lambda_read_statistics_from_exercises_table.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "veet_code_questions_table"
  }
}
