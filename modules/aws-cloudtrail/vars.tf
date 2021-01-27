# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the CloudTrail 'trail' to create."
  type        = string
  default     = "quantum-trail"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "kms_key_additional_iam_policy" {
  description = "An IAM policy document to import and override the current policy document. Statements with non-blank sids in the override document will overwrite statements with the same sid in the current document. Statements without a sid cannot be overwritten."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "If you wish to specify a custom KMS key, then specify the key arn using this variable.  `create_dedicated_kms_cloudtrail_key` must be set to `false` to lookup this kms key. This is especially useful when using CloudTrail with multiple AWS accounts, so the logs are all encrypted using the same key."
  type        = string
  default     = null
}

variable "aws_account_ids" {
  description = "A list of AWS Account IDs for which cloudtrail will permitted to write to the S3 bucket."
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

variable "notify_sns_topic_name" {
  description = "Specifies the name of the Amazon SNS topic defined for notification of log file delivery."
  type        = string
  default     = null
}

variable "enable_cloudtrail_bucket_access_logging" {
  # https://docs.aws.amazon.com/AmazonS3/latest/user-guide/server-access-logging.html
  description = "Toggle access logging of this S3 bucket."
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enables logging for the trail. Setting this to `false` will pause logging."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Specifies whether CloudTrail will log only API calls in the current region or in all regions."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "If set to true, when you run 'terraform destroy', delete all objects from the bucket so that the bucket can be destroyed without error. Warning: these objects are not recoverable so only use this if you're absolutely sure you want to permanently delete everything!"
  type        = bool
  default     = false
}

variable "enable_data_logging" {
  description = "Enable the logging of data events.  See https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html for details on data logging."
  type        = bool
  default     = false
}

variable "data_logging_read_write_type" {
  description = "The type of data events to log. Possible values are: `ReadOnly`, `WriteOnly`, `All`."
  type        = string
  default     = "All"

  validation {
    condition     = var.data_logging_read_write_type == "ReadOnly" || var.data_logging_read_write_type == "WriteOnly" || var.data_logging_read_write_type == "All"
    error_message = "The value for `data_logging_read_write_type` must be one of `ReadOnly`, `WriteOnly`, or `All`."
  }
}

variable "data_logging_include_management_events" {
  description = "Specify if you want your event selector to include management events for your trail."
  type        = bool
  default     = true
}

variable "data_logging_resource_type" {
  # https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html#API_DataResource_Contents
  # The resource type in which you want to log data events. You can specify `AWS::S3::Object` or `AWS::Lambda::Function` resources.
  # The `AWS::S3Outposts::Object` resource type is not valid in basic event selectors. To log data events on this resource type, use advanced event selectors.
  description = "The resource type in which you want to log data events.  Requires `data_logging_include_management_events` to be set to `true`. Possible values are: `AWS::S3::Object`, `AWS::S3Outposts::Object`, or `AWS::Lambda::Function`."
  type        = string
  default     = "AWS::S3::Object"

  validation {
    condition     = var.data_logging_resource_type == "AWS::S3::Object" || var.data_logging_resource_type == "AWS::S3Outposts::Object" || var.data_logging_resource_type == "AWS::Lambda::Function"
    error_message = "The value for `data_logging_resource_type` must be one of `AWS::S3::Object`, `AWS::S3Outposts::Object`, or `AWS::Lambda::Function`."
  }
}

variable "data_logging_resource_values" {
  # https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html#API_DataResource_Contents
  # To log data events for all objects in all S3 buckets in your AWS account, specify the prefix as `arn:aws:s3:::`
  # To log data events for all objects in an S3 bucket, specify the bucket and an empty object prefix such as `arn:aws:s3:::bucket-1/`. The trail logs data events for all objects in this S3 bucket.
  # To log data events for specific objects, specify the S3 bucket and object prefix such as `arn:aws:s3:::bucket-1/example-images`. The trail logs data events for objects in this S3 bucket that match the prefix.
  # To log data events for all functions in your AWS account, specify the prefix as `arn:aws:lambda`.
  # To log data events for a specific Lambda function, specify the function ARN.
  description = "A list of resource ARNs for data event logging.  See https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html#API_DataResource_Contents for how to specify values."
  type        = list(string)
  default = [
    "arn:aws:s3:::"
  ]
}

variable "enable_insight_logging" {
  type        = bool
  description = "Enables insight for identifying unusual operational activity."
  default     = false
}

variable "enable_insight_types" {
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-insights-events-with-cloudtrail.html
  # Insights events are logged when CloudTrail detects unusual write management API activity in your account.
  # If you have CloudTrail Insights enabled, and CloudTrail detects unusual activity, Insights events are delivered to the destination S3 bucket for your trail.
  # You can also see the type of insight and the incident time period when you view Insights events on the CloudTrail console.
  # Unlike other types of events captured in a CloudTrail trail, Insights events are logged only when CloudTrail detects changes in your account's API usage
  # that differ significantly from the account's typical usage patterns.
  type        = set(string)
  description = "Specifies an insight types for identifying unusual operational activity.  Only `ApiCallRateInsight` is supported as an insight type."
  default = [
    "ApiCallRateInsight"
  ]

  validation {
    condition     = length(setsubtract(var.enable_insight_types, ["ApiCallRateInsight"])) == 0
    error_message = "Value must be a set.  Only `ApiCallRateInsight` is supported as an insight type."
  }
}

variable "worm_mode" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes
  type        = string
  description = "The default Object Lock retention mode you want to apply to new objects placed in this bucket. Valid values are GOVERNANCE and COMPLIANCE."
  default     = "GOVERNANCE"
}

variable "worm_retention_days" {
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-periods
  type        = number
  description = "The number of days an object version will be locked from deletion. If the `worm_mode` is set to GOVERNANCE then user with either s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration may bypass this restriction, otherwise the object may not be deleted for this many days."
  default     = 365
}

variable "create_cloudtrail" {
  description = "Setting this to false will skip creating the trail.  This allows us to create a trail in the root organization account, separating the s3 bucket into a dedicated to audit/logging."
  type        = bool
  default     = true
}

variable "create_dedicated_kms_cloudtrail_key" {
  description = "Setting this to false will skip creating the dedicated kms key.  This allows us to reference a CMK that is managed outside of this module (useful for organization trail)."
  type        = bool
  default     = true
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

variable "s3_key_prefix" {
  description = "Specifies the S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  type        = string
  default     = null
}

variable "dependencies" {
  # https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
  description = "Support module dependencies. Resources within this module will not be created until the dependencies exist and will not be destroyed before the resources in the list are destroyed."
  type        = list(any)
  default     = []
}
