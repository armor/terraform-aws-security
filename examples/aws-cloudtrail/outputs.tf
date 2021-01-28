output "trail_arn" {
  description = "The ARN of the cloudtrail trail."
  value       = module.aws_cloudtrail.trail_arn
}

output "trail_name" {
  description = "The name of the cloudtrail trail."
  value       = module.aws_cloudtrail.trail_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket where cloudtrail logs are delivered."
  value       = module.aws_cloudtrail.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where cloudtrail logs are delivered."
  value       = module.aws_cloudtrail.s3_bucket_arn
}

output "s3_access_logging_bucket_arn" {
  description = "The ARN of the S3 bucket where server access logs are delivered."
  value       = module.aws_cloudtrail.s3_access_logging_bucket_arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used by the S3 bucket to encrypt cloudtrail logs."
  value       = module.aws_cloudtrail.kms_key_arn
}

output "kms_key_alias" {
  description = "The ARN of the KMS key used by the S3 bucket to encrypt cloudtrail logs."
  value       = module.aws_cloudtrail.kms_key_alias
}
