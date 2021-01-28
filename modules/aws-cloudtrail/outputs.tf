output "trail_arn" {
  description = "The ARN of the cloudtrail trail."
  value       = local.create_cloudtrail ? aws_cloudtrail.cloudtrail[0].arn : null
}

output "trail_name" {
  description = "The name of the cloudtrail trail."
  value       = local.create_cloudtrail ? aws_cloudtrail.cloudtrail[0].name : null
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket where cloudtrail logs are delivered."
  value       = local.create_s3_bucket ? module.bucket[0].id : null
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where cloudtrail logs are delivered."
  value       = local.create_s3_bucket ? module.bucket[0].arn : null
}

output "s3_access_logging_bucket_arn" {
  description = "The ARN of the S3 bucket where server access logs are delivered."
  value       = local.create_s3_bucket ? module.bucket[0].bucket_logging_arn : null
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used by the S3 bucket to encrypt cloudtrail logs."
  value       = local.kms_key_arn
}

output "kms_key_alias" {
  description = "The ARN of the KMS key used by the S3 bucket to encrypt cloudtrail logs."
  value       = local.kms_key_alias
}

output "organization_id" {
  description = "The Id of the AWS Organization that this account is a member of."
  value       = local.organization_id
}
