variable "name" {
  description = "This will be prefixed to create the AWS resources. 'example' will create a bucket named 'example-aws-config-s3-bucket'"
  type        = string
}

variable "enable_aws_config" {
  description = "Boolean toggle to turn of and off the AWS Config recording"
  type        = bool
}

variable "sns_topic_arn" {
  description = "(Optional) ARN of SNS topic for the AWS Config to deliver messages"
  type        = string
  default     = null
}
