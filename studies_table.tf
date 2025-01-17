resource "aws_dynamodb_table" "studies" {
  name         = "studies_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "study_theme"
    type = "S"
  }

  attribute {
    name = "study_date"
    type = "S"
  }

  attribute {
    name = "minutes_of_study"
    type = "N"
  }

  hash_key = "study_theme"
  range_key = "study_date"

  global_secondary_index {
    name            = "study_date_index"
    hash_key        = "study_date"
    range_key       = "study_theme"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "minutes_of_study_index"
    hash_key        = "study_theme"
    range_key       = "minutes_of_study"
    projection_type = "ALL"
  }
}
