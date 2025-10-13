resource "aws_dynamodb_table" "hammocker_recommendations" {
  name         = "hammocker_recommendations_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "recommendation_id"
    type = "S"
  }

  hash_key = "recommendation_id"

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
    Module  = "Recommendations"
    Purpose = "AIRecommendationSessions"
  }
}
