output "arn" {
  description = "The ARN of the customer master key."
  value       = aws_s3_bucket.private_s3.arn
}

output "id" {
  description = "The unique identifier of the customer master key."
  value       = aws_s3_bucket.private_s3.id
}

output "bucket_logging_enabled" {
  description = "value"
  value       = can(count(aws_s3_bucket.private_s3_logs.*.id))
}

output "bucket_logging_arn" {
  description = "value"
  value       = try(aws_s3_bucket.private_s3_logs[0].arn, null)
}

output "block_public_acls" {
  description = "value"
  value       = aws_s3_bucket_public_access_block.private_access.block_public_acls
}

output "block_public_policy" {
  description = "value"
  value       = aws_s3_bucket_public_access_block.private_access.block_public_policy
}

output "ignore_public_acls" {
  description = "value"
  value       = aws_s3_bucket_public_access_block.private_access.ignore_public_acls
}

output "restrict_public_buckets" {
  description = "value"
  value       = aws_s3_bucket_public_access_block.private_access.restrict_public_buckets
}
