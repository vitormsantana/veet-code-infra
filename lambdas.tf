resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "veet-code-lambda-artifacts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "lambda_artifacts" {
  bucket                  = aws_s3_bucket.lambda_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_render_card" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "lambda_render_card/lambda_render_card.zip"
  source = "${path.module}/lambdas/lambda_render_card/lambda_render_card.zip"
  etag   = filemd5("${path.module}/lambdas/lambda_render_card/lambda_render_card.zip")
}

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

module "lambda_render_card" {
  source            = "./lambdas/module"
  lambda_name       = "lambda_render_card"
  zip_file          = "${path.module}/lambdas/lambda_render_card/lambda_render_card.zip"
  deploy_from_s3    = true
  s3_bucket         = aws_s3_object.lambda_render_card.bucket
  s3_key            = aws_s3_object.lambda_render_card.key
  s3_object_version = aws_s3_object.lambda_render_card.version_id
  lambda_role_arn   = aws_iam_role.lambda_exec.arn

  handler = "index.handler"
  runtime = "nodejs20.x"

  timeout     = 60
  memory_size = 1024

  env_vars = {
    BUCKET            = aws_s3_bucket.hammocker_public.bucket
    CLOUDFRONT_DOMAIN = aws_s3_bucket.hammocker_public.bucket_regional_domain_name
  }
}

