resource "aws_dynamodb_table" "hammocker_user_profiles" {
  name         = "hammocker_user_profiles_table"
  billing_mode = "PAY_PER_REQUEST"

  # Primary key: one item per user
  attribute {
    name = "user_id"
    type = "S"
  }

  hash_key = "user_id"

  # Additional attributes
  attribute {
    name = "target_companies"
    type = "S"
  }

  attribute {
    name = "desired_role"
    type = "S"
  }

  attribute {
    name = "country_target"
    type = "S"
  }

  attribute {
    name = "main_stack"
    type = "S"
  }

  # Global Secondary Indexes (for filtering/grouping users)
  global_secondary_index {
    name            = "company-index"
    hash_key        = "target_companies"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "role-index"
    hash_key        = "desired_role"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "country-index"
    hash_key        = "country_target"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "stack-index"
    hash_key        = "main_stack"
    projection_type = "ALL"
  }

  tags = {
    Project = "Hammocker"
    Module  = "UserProfile"
    Purpose = "Personalized Recommendations"
  }
}
