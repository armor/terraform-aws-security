output "bucket_arn" {
  description = "The ARN of the customer master key."
  value       = module.aws_s3_bucket_private.arn
}

output "bucket_id" {
  description = "The unique identifier of the customer master key."
  value       = module.aws_s3_bucket_private.id
}

output "bucket_logging_enabled" {
  description = "value"
  value       = module.aws_s3_bucket_private.bucket_logging_enabled
}
