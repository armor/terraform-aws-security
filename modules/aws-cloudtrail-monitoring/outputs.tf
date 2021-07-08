output "sns_topic_name" {
  description = "The name of the SNS topic to which alarms will be forwarded."
  value       = aws_sns_topic.alarms.name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic to which alarms will be forwarded."
  value       = aws_sns_topic.alarms.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group to which CloudTrail logs will be sent."
  value       = aws_cloudwatch_log_group.events.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group to which CloudTrail logs will be sent."
  value       = aws_cloudwatch_log_group.events.arn
}

output "cloudwatch_role_arn" {
  description = "The ARN of the IAM role used by CloudTrail to forward events to CloudWatch."
  value       = aws_iam_role.cloudwatch_logs_role.arn
}
