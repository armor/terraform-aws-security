output "arn" {
  description = "The ARN of the private S3 Bucket."
  value       = aws_s3_bucket.private_s3.arn
}

output "id" {
  description = "The name of the private S3 Bucket."
  value       = aws_s3_bucket.private_s3.id
}

output "bucket_logging_enabled" {
  description = "Whether or not access logging is enabled for this bucket."
  value       = try(var.logging_enabled ? length(local.logging_bucket_arn) : 0, 0) > 0
}

output "bucket_logging_arn" {
  description = "The target ARN of the private S3 Bucket where access logs are stored."
  value       = local.logging_bucket_arn != "" ? local.logging_bucket_arn : null
}

output "block_public_acls" {
  description = "Whether Amazon S3 blocks new public ACLs for this bucket."
  value       = aws_s3_bucket_public_access_block.private_access.block_public_acls
}

output "block_public_policy" {
  description = "Whether Amazon S3 blocks new public bucket policies for this bucket."
  value       = aws_s3_bucket_public_access_block.private_access.block_public_policy
}

output "ignore_public_acls" {
  description = "Whether Amazon S3 ignores existing public ACLs for this bucket."
  value       = aws_s3_bucket_public_access_block.private_access.ignore_public_acls
}

output "restrict_public_buckets" {
  description = "Whether or not public bucket policies are restricted for this bucket."
  value       = aws_s3_bucket_public_access_block.private_access.restrict_public_buckets
}
