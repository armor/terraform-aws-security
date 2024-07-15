# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the trail. This will be used in the creation of the s3 bucket and can also be used in the creation of the access logging bucket if `enable_logging` is true."
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

variable "aws_account_ids" {
  description = "A list of AWS Account IDs that will be permit cloudtrail to write to this bucket."
  type        = list(string)
  default     = []
}


variable "is_organization_trail" {
  # If this is set to `true` while not running under the context of the aws organization management account then an error similar to the following may be returned.
  # Error: Error creating CloudTrail: InsufficientEncryptionPolicyException: Insufficient permissions to access S3 bucket cloudtrail-... or KMS key arn:aws:kms:...
  type        = bool
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
  default     = true
}

variable "update_aws_service_access_principals" {
  description = "Setting this to `true` will attempt to add `cloudtrail.amazonaws.com` to the list set in `aws_service_access_principals`.  Import your organization prior to setting this to `true`.  Ensure that you update `aws_service_access_principals` with your current list of allowed services."
  type        = bool
  default     = false

}

variable "aws_service_access_principals" {
  # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
  description = "List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com.  Be careful and do not remove any services that you are currently using."
  type        = set(string)
  default = [
    "config.amazonaws.com",
    // "config-multiaccountsetup.amazonaws.com",
    "sso.amazonaws.com",
  ]
}

#variable "enable_cloudtrail_bucket_access_logging" {
#  description = "Toggles the creation of an additional S3 bucket and configure this private bucket to send access logs to the logging bucket."
#  type        = bool
#  default     = false
#}

variable "kms_key_arn" {
  description = " The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(var.kms_key_arn != null && trimprefix(var.kms_key_arn, "aws:") != var.kms_key_arn)
    error_message = "If set the value must be an ARN beginning with the string 'aws:'."
  }
}

#variable "logging_bucket_name" {
#  description = "The name of the target bucket that will receive the log objects. This defaults to `name`-logs. If `logging_bucket_name` is specified then the named s3 bucket is not created by this module."
#  type        = string
#  default     = null
#}

variable "worm_mode" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html
  type = string
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes
  # If the mode is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration
  # permissions will allow the deletion of locked objects
  description = "Enable Write Once Read Many (WORM). Object-lock Configuration of S3 Bucket can use GOVERNANCE or COMPLIANCE mode. COMPLIANCE can not be removed while GOVERNANCE can be disabled by the root user. `versioning_enabled` must be set to true for this to be enabled. This configuration can only be set on a new S3 bucket, otherwise you will need to contact AWS Support to have it configured."
  default     = "GOVERNANCE"
}

variable "worm_retention_days" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html
  type        = number
  description = "The number of days an object version will be locked from deletion. If the `worm_mode` is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration, otherwise the object may not be deleted for this many days."
  default     = 1
}


#variable "create_s3_bucket" {
#  description = "Setting this to false will skip creating the S3 bucket.  This allows us to create an S3 bucket in a separate account, dedicated to audit/logging, and reference the bucket here (useful for organization trail)."
#  type        = bool
#  default     = true
#}

variable "s3_bucket_name" {
  description = "Setting this value will override the computed bucket name.  If you set `create_s3_bucket` to `false` then you will need to provide a value for this variable."
  type        = string
  default     = null
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource.  Tags are useful to demonstrate COGM/COGS."
  type        = map(string)
  default = {
    cost_center = "engineering"
    department  = "security_engineering"
    team        = "cloud_security"
    stack       = "security_events"
    project     = "armor"
    service     = "cloudtrail"
    application = "sentinel"
  }
}
