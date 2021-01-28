# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "bucket_name" {
  description = "What to name the S3 bucket. Note that S3 bucket names must be globally unique across all AWS users!"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_account_ids" {
  description = "A list of AWS Account IDs that will be permit cloudtrail to write to this bucket."
  type        = list(string)
  default     = []
}

variable "organization_id" {
  # https://console.aws.amazon.com/organizations/home?#/organization/overview
  description = "The unique identifier (ID) of an organization.  Only set this to a value if this bucket is used as a common cloudtrail bucket for an organization trail."
  type        = string
  default     = null

  validation {
    # https://docs.aws.amazon.com/organizations/latest/APIReference/API_Organization.html
    condition     = var.organization_id == null || can(regex("^(o-[a-z0-9]{10,32})$", var.organization_id))
    error_message = "The Organization Id is in the incorrect format."
  }
}

variable "bucket_key_prefix" {
  description = "Specifies the S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "kms_master_key_arn" {
  description = " The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  type        = string
  default     = null

  validation {
    condition     = var.kms_master_key_arn == null || can(var.kms_master_key_arn != null && trimprefix(var.kms_master_key_arn, "aws:") != var.kms_master_key_arn)
    error_message = "If set the value must be an ARN beginning with the string 'aws:'."
  }
}

variable "access_logging_bucket_name" {
  description = "The name of the target bucket that will receive the log objects. This defaults to `name`-logs. If `access_logging_bucket_name` is specified then the named s3 bucket is not created by this module."
  type        = string
  default     = null
}

variable "access_logging_bucket_prefix" {
  # https://docs.aws.amazon.com/general/latest/gr/glos-chap.html#keyprefix
  description = "To specify a key prefix for log objects. This prefix is used to prefix server access log objects when `logging_enabled` is `true` and generally should only be used when multiple s3 buckets are logging to a single s3 bucket which can be defined with `access_logging_bucket_name`. Key prefixes are useful to distinguish between source buckets when multiple buckets log to the same target bucket."
  type        = string
  default     = ""
}

variable "enable_cloudtrail_bucket_access_logging" {
  # https://docs.aws.amazon.com/AmazonS3/latest/user-guide/server-access-logging.html
  description = "Toggle access logging of this S3 bucket."
  type        = bool
  default     = true
}

variable "worm_mode" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes
  type        = string
  description = "The default Object Lock retention mode you want to apply to new objects placed in this bucket. Valid values are GOVERNANCE and COMPLIANCE."
  default     = "GOVERNANCE"
  validation {
    condition     = var.worm_mode == "GOVERNANCE" || var.worm_mode == "COMPLIANCE"
    error_message = "The value for `worm_mode` must be either GOVERNANCE or COMPLIANCE."
  }
}

variable "worm_retention_days" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-periods
  type        = number
  description = "The number of days an object version will be locked from deletion. If the `worm_mode` is set to GOVERNANCE then user with either s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration may bypass this restriction, otherwise the object may not be deleted for this many days."
  default     = 1
  validation {
    condition     = var.worm_retention_days >= 1
    error_message = "The value for `worm_retention_days` must be equal to or greater than 1."
  }
}

variable "policy_json" {
  description = "Additional base S3 bucket policy in JSON format."
  type        = string
  default     = "{}"
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
