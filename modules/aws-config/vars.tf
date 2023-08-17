variable "name" {
  description = "This will be prefixed to create the AWS resources. 'example' will create a bucket named 'example-aws-config-s3-bucket'"
  type        = string
}

variable "enable_aws_config" {
  description = "Boolean toggle to turn on and off the AWS Config recording"
  type        = bool
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for the AWS Config to deliver messages"
  type        = string
  default     = null
}

variable "max_access_key_age" {
  description = "Maximum number of days without rotation."
  default     = 90
  type        = number

}

variable "max_password_age" {
  description = "The number of days that an user password is valid."
  default     = 90
  type        = number
}

variable "minimum_password_length" {
  description = "Minimum length to require for user passwords."
  default     = 14
  type        = number
}

variable "password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing."
  default     = 24
  type        = number
}

variable "require_lowercase_characters" {
  description = "Whether to require lowercase characters for user passwords."
  default     = true
  type        = bool
}

variable "require_numbers" {
  description = "Whether to require numbers for user passwords."
  default     = true
  type        = bool
}

variable "require_uppercase_characters" {
  description = "Whether to require uppercase characters for user passwords."
  default     = true
  type        = bool
}

variable "require_symbols" {
  description = "Whether to require symbols for user passwords."
  default     = true
  type        = bool
}
