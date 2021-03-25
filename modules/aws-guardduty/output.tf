output "useast1_detector_id" {
  description = "The ID of the GuardDuty detector for us-east-1"
  value       = contains(var.aws_regions, "us-east-1") ? aws_guardduty_detector.useast1[*].id : null
}

output "useast2_detector_id" {
  description = "The ID of the GuardDuty detector for us-east-2"
  value       = contains(var.aws_regions, "us-east-2") ? aws_guardduty_detector.useast2[*].id : null
}

output "uswest1_detector_id" {
  description = "The ID of the GuardDuty detector for us-west-1"
  value       = contains(var.aws_regions, "us-west-1") ? aws_guardduty_detector.uswest1[*].id : null
}

output "uswest2_detector_id" {
  description = "The ID of the GuardDuty detector for us-west-2"
  value       = contains(var.aws_regions, "us-west-2") ? aws_guardduty_detector.uswest2[*].id : null
}

output "cacentral1_detector_id" {
  description = "The ID of the GuardDuty detector for ca-central-1"
  value       = contains(var.aws_regions, "ca-central-1") ? aws_guardduty_detector.cacentral1[*].id : null
}

output "eucentral1_detector_id" {
  description = "The ID of the GuardDuty detector for eu-central-1"
  value       = contains(var.aws_regions, "eu-central-1") ? aws_guardduty_detector.eucentral1[*].id : null
}

output "euwest1_detector_id" {
  description = "The ID of the GuardDuty detector for eu-west-1"
  value       = contains(var.aws_regions, "eu-west-1") ? aws_guardduty_detector.euwest1[*].id : null
}

output "euwest2_detector_id" {
  description = "The ID of the GuardDuty detector for eu-west-2"
  value       = contains(var.aws_regions, "eu-west-2") ? aws_guardduty_detector.euwest2[*].id : null
}

output "euwest3_detector_id" {
  description = "The ID of the GuardDuty detector for eu-west-3"
  value       = contains(var.aws_regions, "eu-west-3") ? aws_guardduty_detector.euwest3[*].id : null
}

output "eunorth1_detector_id" {
  description = "The ID of the GuardDuty detector for eu-north-1"
  value       = contains(var.aws_regions, "eu-north-1") ? aws_guardduty_detector.eunorth1[*].id : null
}

output "apnortheast1_detector_id" {
  description = "The ID of the GuardDuty detector for ap-northeast-1"
  value       = contains(var.aws_regions, "ap-northeast-1") ? aws_guardduty_detector.apnortheast1[*].id : null
}

output "apnortheast2_detector_id" {
  description = "The ID of the GuardDuty detector for ap-northeast-2"
  value       = contains(var.aws_regions, "ap-northeast-2") ? aws_guardduty_detector.apnortheast2[*].id : null
}

output "apsoutheast1_detector_id" {
  description = "The ID of the GuardDuty detector for ap-southeast-1"
  value       = contains(var.aws_regions, "ap-southeast-1") ? aws_guardduty_detector.apsoutheast1[*].id : null
}

output "apsoutheast2_detector_id" {
  description = "The ID of the GuardDuty detector for ap-southeast-2"
  value       = contains(var.aws_regions, "ap-southeast-2") ? aws_guardduty_detector.apsoutheast2[*].id : null
}

output "apsouth1_detector_id" {
  description = "The ID of the GuardDuty detector for ap-south-1"
  value       = contains(var.aws_regions, "ap-south-1") ? aws_guardduty_detector.apsouth1[*].id : null
}

output "saeast1_detector_id" {
  description = "The ID of the GuardDuty detector for sa-east-1"
  value       = contains(var.aws_regions, "sa-east-1") ? aws_guardduty_detector.saeast1[*].id : null
}
