resource "aws_dynamodb_table" "veet_code_questions" {
  name           = "veet_code_questions_table"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "question_id"
    type = "S"
  }

  hash_key = "question_id"

  attribute {
    name = "difficulty"
    type = "S"
  }

  attribute {
    name = "tag"
    type = "S"
  }

  global_secondary_index {
    name            = "difficulty-index"
    hash_key        = "difficulty"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "tag-index"
    hash_key        = "tag"
    projection_type = "ALL"
  }
}
