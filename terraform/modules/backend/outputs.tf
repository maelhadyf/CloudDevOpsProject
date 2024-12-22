output "state_bucket_name" {
  description = "Name of the S3 bucket for state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.id
}
