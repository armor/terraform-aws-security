output "trail_arn" {
  description = "The ARN of the cloudtrail trail."
  value       = local.create_cloudtrail ? module.aws_cloudtrail[0].trail_arn : null
}

output "trail_name" {
  description = "The name of the cloudtrail trail."
  value       = local.create_cloudtrail ? module.aws_cloudtrail[0].trail_name : null
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket where cloudtrail logs are delivered."
  value       = local.create_s3_bucket ? module.aws_cloudtrail[0].s3_bucket_name : null
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where cloudtrail logs are delivered."
  value       = local.create_s3_bucket ? module.aws_cloudtrail[0].s3_bucket_arn : null
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used by the S3 bucket to encrypt cloudtrail logs."
  value       = local.create_kms_key ? module.aws_cloudtrail[0].kms_key_arn : null
}

output "organization_id" {
  description = "The Id of the AWS Organization that this account is a member of."
  value       = local.is_organization_trail ? module.aws_cloudtrail[0].organization_id : null
}
