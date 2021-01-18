# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the s3 bucket.  This can also be used in the creation of the logging bucket if var.enable_logging is true."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS Region to deploy this resource into."
  type        = string
  default     = "ap-southeast-1"
}

variable "enable_logging" {
  description = "Toggles the creation of an additional S3 bucket and configure this private bucket to send access logs to the logging bucket."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
