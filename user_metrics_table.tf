resource "aws_dynamodb_table" "hammocker_user_metrics" {
  name         = "hammocker_user_metrics_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  hash_key  = "user_id"
  range_key = "date"

  tags = {
    Project = "Hammocker"
    Module  = "UserMetrics"
    Purpose = "ExercisePerformanceTracking"
  }
}
