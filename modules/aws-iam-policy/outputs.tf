output "id" {
  description = "The unqiue identifier of this IAM policy."
  value       = aws_iam_policy.policy.id
}

output "arn" {
  description = "The ARN assigned by AWS to this IAM policy."
  value       = aws_iam_policy.policy.arn
}
