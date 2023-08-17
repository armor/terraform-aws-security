# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the trail. This will be used in the creation of the s3 bucket and can also be used in the creation of the access logging bucket if `enable_logging` is true."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account number in which these resources are provisioned."
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
  description = "A list of AWS Account IDs that will be permit cloudtrail to write to this bucket.  A value of `*` will permit cloudtrail from all accounts."
  type        = list(string)
  default     = ["*"]
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

variable "create_s3_bucket" {
  description = "Setting this to false will skip creating the S3 bucket.  This allows us to create an S3 bucket in a separate account, dedicated to audit/logging, and reference the bucket here (useful for organization trail)."
  type        = bool
  default     = true
}

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
    project     = "quantum"
    service     = "cloudtrail"
    application = "sentinel"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CMK for Cloudwatch SNS encryption
# ---------------------------------------------------------------------------------------------------------------------

variable "deletion_window_in_days" {
  description = "The number of days to retain this CMK after it has been marked for deletion."
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Whether or not to automatic annual rotation of the CMK is enabled."
  type        = bool
  default     = true
}

variable "customer_master_key_spec" {
  description = "Whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Any of `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "key_usage" {
  description = "Specifies the intended use of the key."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}
