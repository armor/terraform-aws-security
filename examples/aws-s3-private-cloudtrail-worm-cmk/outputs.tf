output "bucket_arn" {
  description = "The ARN of the customer master key."
  value       = module.aws_s3_private_cloudtrail.arn
}

output "bucket_id" {
  description = "The unique identifier of the customer master key."
  value       = module.aws_s3_private_cloudtrail.id
}

output "bucket_logging_enabled" {
  description = "Whether or not access logging is enabled for this bucket."
  value       = module.aws_s3_private_cloudtrail.bucket_logging_enabled
}

output "bucket_logging_arn" {
  description = "The target ARN of the private S3 Bucket where access logs are stored."
  value       = module.aws_s3_private_cloudtrail.bucket_logging_arn
}

output "kms_arn" {
  description = "The ARN for the KMS key used by S3 for server side encryption of cloudtrail logs."
  value       = local.kms_master_key_arn
}
