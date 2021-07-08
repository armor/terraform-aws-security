variable "aws_region" {
  description = "The AWS region in which this module is deployed."
  type        = string
  default     = "us-east-1"
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Logs group to which CloudTrail events are delivered."
  type        = string
  default     = "example-cloudtrail-log-group"
}
