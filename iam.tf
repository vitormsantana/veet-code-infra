data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_exec" {
  name = "veet-code-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "veet-code-lambda-dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:sa-east-1:${data.aws_caller_identity.current.account_id}:table/veet_code_questions_table",
          "arn:aws:dynamodb:sa-east-1:${data.aws_caller_identity.current.account_id}:table/veet_code_questions_table/index/*",
          "arn:aws:dynamodb:sa-east-1:${data.aws_caller_identity.current.account_id}:table/hammocker_user_profiles_table",
          "arn:aws:dynamodb:sa-east-1:${data.aws_caller_identity.current.account_id}:table/hammocker_user_profiles_table/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_render_card_s3_access" {
  name = "veet-code-lambda-render-card-s3-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.hammocker_public.arn}/share-cards/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_frontend_events_s3_access" {
  name = "veet-code-lambda-frontend-events-s3-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.frontend_events.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.frontend_events.arn}/${var.frontend_event_reciever_events_prefix}/*"
      }
    ]
  })
}
