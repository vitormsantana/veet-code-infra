resource "aws_dynamodb_table" "veet_code_questions" {
  name         = "veet_code_questions_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "question_name"
    type = "S"
  }

  hash_key = "question_name"

  attribute {
    name = "question_solved_date"
    type = "S"
  }

  range_key = "question_solved_date"

  attribute {
    name = "difficulty"
    type = "S"
  }

  attribute {
    name = "tags"
    type = "S"
  }

  global_secondary_index {
    name            = "difficulty-index"
    hash_key        = "difficulty"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "tags-index"
    hash_key        = "tags"
    projection_type = "ALL"
  }
}
