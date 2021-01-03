output "key_arn" {
  description = "The ARN of the customer master key."
  value       = aws_kms_key.master_key.arn
}

output "key_id" {
  description = "The unique identifier of the customer master key."
  value       = aws_kms_key.master_key.id
}

output "key_alias" {
  description = "The name of the customer master key alias."
  value       = aws_kms_alias.master_key.name
}
