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

module "lambda_read_openai_questions_recomendations" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_read_openai_questions_recomendations"
  zip_file        = "${path.module}/lambdas/lambda_read_openai_questions_recomendations/lambda_read_openai_questions_recomendations.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "veet_code_questions_table"
    OPENAI_API_KEY = var.openai_api_key
  }
}

module "lambda_add_profile_infos" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_add_profile_infos"
  zip_file        = "${path.module}/lambdas/lambda_add_profile_infos/lambda_add_profile_infos.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "hammocker_user_profiles_table"
  }
}

module "lambda_read_profile_infos" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_read_profile_infos"
  zip_file        = "${path.module}/lambdas/lambda_read_profile_infos/lambda_read_profile_infos.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn

  env_vars = {
    DYNAMODB_TABLE = "hammocker_user_profiles_table"
  }
}

module "lambda_add_user_metrics" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_add_user_metrics"
  zip_file        = "${path.module}/lambdas/lambda_add_user_metrics/lambda_add_user_metrics.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn
 }


module "lambda_read_metrics_from_users" {
  source          = "./lambdas/module"
  lambda_name     = "lambda_read_metrics_from_users"
  zip_file        = "${path.module}/lambdas/lambda_read_metrics_from_users/lambda_read_metrics_from_users.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn
 }


module "lambda_add_feedback_for_recomendation" {
  source          = "./lambdas/module"
  lambda_name     = "add_feedback_for_recomendation"
  zip_file        = "${path.module}/lambdas/add_feedback_for_recomendation/add_feedback_for_recomendation.zip"
  lambda_role_arn = aws_iam_role.lambda_exec.arn
  env_vars = {
    OPENAI_API_KEY = var.openai_api_key
  }
  }

