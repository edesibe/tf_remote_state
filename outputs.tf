output "s3_bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "Bucket ID"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID"
}

output "s3_policy" {
  value       = data.aws_iam_policy_document.state_force_ssl.json
  description = "IAM policy attached to the S3 bucket"
}
