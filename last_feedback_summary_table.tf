resource "aws_dynamodb_table" "hammocker_last_feedback_summaries" {
  name         = "hammocker_last_feedback_summaries_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "analyzed_at_utc"
    type = "S"
  }

  hash_key  = "user_id"
  range_key = "analyzed_at_utc"

  tags = {
    Project = "Hammocker"
    Module  = "UserFeedback"
    Purpose = "RecentFeedbackSummaries"
  }
}
