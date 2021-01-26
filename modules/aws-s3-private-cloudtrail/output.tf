output "arn" {
  description = "The ARN of the private S3 Bucket."
  value       = module.s3_private.arn
}

output "id" {
  description = "The name of the private S3 Bucket."
  value       = module.s3_private.id
}

output "bucket_logging_enabled" {
  description = "Whether or not access logging is enabled for this bucket."
  value       = module.s3_private.bucket_logging_enabled
}

output "bucket_logging_arn" {
  description = "The target ARN of the private S3 Bucket where access logs are stored."
  value       = module.s3_private.bucket_logging_arn
}

output "block_public_acls" {
  description = "Whether Amazon S3 blocks new public ACLs for this bucket."
  value       = module.s3_private.block_public_acls
}

output "block_public_policy" {
  description = "Whether Amazon S3 blocks new public bucket policies for this bucket."
  value       = module.s3_private.block_public_policy
}

output "ignore_public_acls" {
  description = "Whether Amazon S3 ignores existing public ACLs for this bucket."
  value       = module.s3_private.ignore_public_acls
}

output "restrict_public_buckets" {
  description = "Whether or not public bucket policies are restricted for this bucket."
  value       = module.s3_private.restrict_public_buckets
}
