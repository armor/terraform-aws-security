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

variable "allow_s3_integration_services" {
  description = "Add a secure s3 bucket policy allowing s3 services to PutItem into the bucket. Used by Analytics and Inventory."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "kms_master_key_arn" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default `aws/s3` AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`."
  type        = string
  default     = null

  validation {
    condition     = var.kms_master_key_arn == null || can(var.kms_master_key_arn != null && trimprefix(var.kms_master_key_arn, "aws:") != var.kms_master_key_arn)
    error_message = "If set the value must be an ARN beginning with the string 'aws:'."
  }
}

variable "logging_bucket_name" {
  description = "The name of the target bucket that will receive the log objects. This defaults to `name`-logs. If `logging_bucket_name` is specified then the named s3 bucket is not created by this module."
  type        = string
  default     = null
}

variable "logging_bucket_prefix" {
  # https://docs.aws.amazon.com/general/latest/gr/glos-chap.html#keyprefix
  description = "To specify a key prefix for log objects. This prefix is used to prefix server access log objects when `logging_enabled` is `true` and generally should only be used when multiple s3 buckets are logging to a single s3 bucket which can be defined with `logging_bucket_name`. Key prefixes are useful to distinguish between source buckets when multiple buckets log to the same target bucket."
  type        = string
  default     = ""
}

variable "logging_enabled" {
  # https://docs.aws.amazon.com/AmazonS3/latest/user-guide/server-access-logging.html
  description = "Toggle access logging of this S3 bucket."
  type        = bool
  default     = true

}

variable "object_lock_configuration" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html
  type = object({
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes
    # If the mode is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration
    # permissions will allow the deletion of locked objects
    mode = string
    # minimum 1 days
    days = number
  })
  description = "Enable Write Once Read Many (WORM). Object-lock Configuration of S3 Bucket can use GOVERNANCE or COMPLIANCE mode. COMPLIANCE can not be removed while GOVERNANCE can be disabled by the root user. `versioning_enabled` must be set to true for this to be enabled. This configuration can only be set on a new S3 bucket, otherwise you will need to contact AWS Support to have it configured."
  default     = null
  validation {
    condition     = var.object_lock_configuration == null || can((var.object_lock_configuration.mode == "GOVERNANCE" || var.object_lock_configuration.mode == "COMPLIANCE") && var.object_lock_configuration.days >= 1)
    error_message = "Mode must be either GOVERNANCE or COMPLIANCE. The value for days must be a number with a minimum value of 1."
  }
}

variable "policy_json" {
  description = "Additional base S3 bucket policy in JSON format."
  type        = string
  default     = "{}"
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  type        = string
  default     = "AES256"

  validation {
    condition     = var.sse_algorithm == "AES256" || var.sse_algorithm == "aws:kms"
    error_message = "The value for sse_algorithm must be AES256 or aws:kms. A value of AES256 requires a value to be set for kms_master_key_arn."
  }
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/Versioning.html
  # Versioning is a means of keeping multiple variants of an object in the same bucket. You can use versioning to preserve, retrieve, and restore every version of every object stored in your Amazon S3 bucket. With versioning, you can easily recover from both unintended user actions and application failures. When you enable versioning for a bucket, if Amazon S3 receives multiple write requests for the same object simultaneously, it stores all of the objects.
  # If you enable versioning for a bucket, Amazon S3 automatically generates a unique version ID for the object being stored. In one bucket, for example, you can have two objects with the same key, but different version IDs
  description = "Enables ability to keep multiple variants of an object in the bucket. Versioning can not be disabled once enabled."
  type        = bool
  default     = true
}
