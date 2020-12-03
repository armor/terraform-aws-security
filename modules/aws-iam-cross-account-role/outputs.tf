output "arn" {
  description = "The ARN of the cross-account IAM role."
  value       = aws_iam_role.role.arn
}

output "id" {
  description = "The ID of the cross-account IAM role."
  value       = aws_iam_role.role.id
}
