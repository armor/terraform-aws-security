output "guardduty_account_id" {
  description = "The AWS account ID of the GuardDuty detector."
  value       = aws_guardduty_detector.guardduty.account_id
}

output "guardduty_arn" {
  description = "Amazon Resource Name (ARN) of the GuardDuty detector."
  value       = aws_guardduty_detector.guardduty.arn
}

output "guardduty_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.guardduty.id
}
