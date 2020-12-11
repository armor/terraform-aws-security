output "id" {
  description = "The unique identifier assigned by AWS."
  value       = aws_iam_user.user.unique_id
}

output "arn" {
  description = "The ARN assigned by AWS for this user."
  value       = aws_iam_user.user.arn
}

output "name" {
  description = "The user's username."
  value       = aws_iam_user.user.name
}
