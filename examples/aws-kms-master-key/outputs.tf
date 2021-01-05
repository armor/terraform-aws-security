output "key_arn" {
  description = "The ARN of the customer master key."
  value       = module.aws_kms_master_key.key_arn
}

output "key_id" {
  description = "The unique identifier of the customer master key."
  value       = module.aws_kms_master_key.key_id
}

output "key_alias" {
  description = "The name of the customer master key alias."
  value       = module.aws_kms_master_key.key_alias
}
