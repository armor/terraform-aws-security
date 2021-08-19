output "bucket_arn" {
  description = "The ARN of the private S3 bucket."
  value       = module.aws_s3_bucket_private.arn
}

output "bucket_id" {
  description = "The name of the private S3 bucket."
  value       = module.aws_s3_bucket_private.id
}

output "bucket_logging_enabled" {
  description = "Whether or not access logging is enabled for this bucket."
  value       = module.aws_s3_bucket_private.bucket_logging_enabled
}

output "bucket_logging_arn" {
  description = "The target ARN of the private S3 bucket where access logs are stored."
  value       = module.aws_s3_bucket_private.bucket_logging_arn
}
