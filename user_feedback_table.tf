resource "aws_dynamodb_table" "hammocker_user_feedback" {
  name         = "hammocker_user_feedback_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "feedback_id"
    type = "S"
  }

  attribute {
    name = "feedback_timestamp"
    type = "S"
  }

  hash_key  = "feedback_id"
  range_key = "feedback_timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "user-id-index"
    hash_key        = "user_id"
    projection_type = "ALL"
  }

  tags = {
    Project = "Hammocker"
    Module  = "UserFeedback"
    Purpose = "RecommendationReviewTracking"
  }
}
