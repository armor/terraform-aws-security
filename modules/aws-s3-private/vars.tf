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
  description = "(optional) Add a secure s3 bucket policy allowing s3 services to PutItem into the bucket.  Used by Analytics and Inventory."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "(optional) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "kms_master_key_arn" {
  description = " (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  type        = string
  default     = null

  validation {
    condition     = var.kms_master_key_arn == null || can(var.kms_master_key_arn != null && trimprefix(var.kms_master_key_arn, "aws:") != var.kms_master_key_arn)
    error_message = "If set the value must be an ARN beginning with the string 'aws:'."
  }
}

variable "logging_bucket_name" {
  description = "(optional) The name of the target bucket that will receive the log objects.  This defaults to {var.name}-logs."
  type        = string
  default     = null
}

variable "logging_bucket_prefix" {
  description = "(optional) To specify a key prefix for log objects. when "
  type        = string
  default     = ""
}

variable "logging_enabled" {
  description = "(optional) Toggle access logging of this S3 bucket."
  type        = bool
  default     = true

}

variable "policy_json" {
  description = "(optional) Additional base S3 bucket policy in JSON format."
  type        = string
  default     = "{}"
}

variable "sse_algorithm" {
  description = "(optional) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  type        = string
  default     = "AES256"

  validation {
    condition     = var.sse_algorithm == "AES256" || var.sse_algorithm == "aws:kms"
    error_message = "(optional) The value for sse_algorithm must be AES256 or aws:kms. A value of AES256 requires a value to be set for kms_master_key_arn."
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
  description = "(optional) Enables ability to keep multiple variants of an object in the bucket.  Versioning can not be disabled once enabled."
  type        = bool
  default     = true
}
