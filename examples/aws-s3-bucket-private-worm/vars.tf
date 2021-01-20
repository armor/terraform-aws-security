# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the s3 bucket. This can also be used in the creation of the logging bucket if `enable_logging` is true."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region into which this resource is deployed."
  type        = string
  default     = "ap-southeast-1"
}

variable "enable_logging" {
  description = "Toggles the creation of an additional S3 bucket and configure this private bucket to send access logs to the logging bucket."
  type        = bool
  default     = false
}

variable "worm_mode" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html
  type = string
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes
  # If the mode is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration
  # permissions will allow the deletion of locked objects
  description = "Enable Write Once Read Many (WORM). Object-lock Configuration of S3 Bucket can use GOVERNANCE or COMPLIANCE mode. COMPLIANCE can not be removed while GOVERNANCE can be disabled by the root user. `versioning_enabled` must be set to true for this to be enabled. This configuration can only be set on a new S3 bucket, otherwise you will need to contact AWS Support to have it configured."
  default     = "GOVERNANCE"
  validation {
    condition     = var.worm_mode == "GOVERNANCE" || var.worm_mode == "COMPLIANCE"
    error_message = "Mode must be either GOVERNANCE or COMPLIANCE."
  }
}

variable "worm_retention_days" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html
  type        = number
  description = "The number of days an object version will be locked from deletion. If the `worm_mode` is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration, otherwise the object may not be deleted for this many days."
  default     = 1
  validation {
    condition     = var.worm_retention_days >= 1
    error_message = "The value for worm_retention_days must be equal to or greater than 1."
  }
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
