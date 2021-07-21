variable "unauthorized_api_calls_enabled" {
  description = "The boolean flag whether the unauthorized_api_calls alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "no_mfa_console_signin_enabled" {
  description = "The boolean flag whether the no_mfa_console_signin alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "root_usage_enabled" {
  description = "The boolean flag whether the root_usage alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "iam_changes_enabled" {
  description = "The boolean flag whether the iam_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "cloudtrail_cfg_changes_enabled" {
  description = "The boolean flag whether the cloudtrail_cfg_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "console_signin_failures_enabled" {
  description = "The boolean flag whether the console_signin_failures alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "disable_or_delete_cmk_enabled" {
  description = "The boolean flag whether the disable_or_delete_cmk alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "s3_bucket_policy_changes_enabled" {
  description = "The boolean flag whether the s3_bucket_policy_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "aws_config_changes_enabled" {
  description = "The boolean flag whether the aws_config_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "security_group_changes_enabled" {
  description = "The boolean flag whether the security_group_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "nacl_changes_enabled" {
  description = "The boolean flag whether the nacl_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "network_gw_changes_enabled" {
  description = "The boolean flag whether the network_gw_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "route_table_changes_enabled" {
  description = "The boolean flag whether the route_table_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "vpc_changes_enabled" {
  description = "The boolean flag whether the vpc_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "organizations_changes_enabled" {
  description = "The boolean flag whether the organizations_changes alarm is enabled or not. No resources are created when set to false."
  type        = bool
  default     = true
}

variable "alarm_namespace" {
  description = "The namespace in which all alarms are set up."
  type        = string
  default     = "CloudTrailMonitoringAlarms"
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Logs group to which CloudTrail events are delivered."
  type        = string
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}

variable "kms_master_key_id" {
  description = "The ID or alias of the KMS CMK used to encrypt the SNS topic."
  type        = string
}

variable "cloudwatch_retention_in_days" {
  description = "The number of days to retain CloudTrail events shipped to CloudWatch."
  type        = number
  default     = 30
}

variable "sns_topic_name" {
  description = "The name of the SNS topic created to receive CloudWatch alarms."
  type        = string
  default     = "cloudtrail-monitoring-alarms"
}
