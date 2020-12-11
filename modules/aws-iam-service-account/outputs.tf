output "id" {
  description = "The unique identifier of the service account."
  value       = aws_iam_user.user.unique_id
}

output "arn" {
  description = "The ARN of the service account."
  value       = aws_iam_user.user.arn
}

output "name" {
  description = "The username assigned to the service account."
  value       = aws_iam_user.user.name
}

output "access_key_id" {
  description = "The access key ID assigned to the service account."
  value       = aws_iam_access_key.access_key.id
}

output "secret_access_key" {
  description = "The secret access key assigned to the service account."
  value       = aws_iam_access_key.access_key.secret
}
