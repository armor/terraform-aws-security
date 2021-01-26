# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A CLOUDTRAIL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  // https://www.terraform.io/docs/language/meta-arguments/count.html
  // Version note: Module support for count was added in Terraform 0.13, and previous versions can only use it with resources.
  required_version = ">= 0.13"
}

# ---------------------------------------------------------------------------------------------------------------------
# AD-HOC MODULE DEPENDENCY
# See: https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607  (null_resource implementation)
# See: https://github.com/hashicorp/terraform/issues/1178#issuecomment-473091030  (use of triggers and join())
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "dependency_getter" {
  triggers = {
    instance = join(",", var.dependencies)
  }
}

locals {
  // kms_key_arn will eventually support creating a key here that is dedicated to cloudtrail
  // for now we will look up the kms_key_arn that is passed in, which may be a key id, key arn, alias name or alias arn
  kms_key_arn      = var.kms_key_arn != null ? data.aws_kms_key.user_defined.arn : null
  s3_bucket_name   = var.s3_bucket_name != null ? var.s3_bucket_name : var.name
  create_s3_bucket = var.create_s3_bucket
}

# ----------------------------------------------------------------------------------------------------------------------
# ENABLE CLOUDTRAIL
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_cloudtrail" "cloudtrail" {
  name = var.name

  # Specifies the name of the S3 bucket designated for publishing log files.
  s3_bucket_name = local.create_s3_bucket ? module.bucket[0].id : local.s3_bucket_name

  # Specifies whether the trail is created in the current region or in all regions. Defaults to false.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/receive-cloudtrail-log-files-from-multiple-regions.html
  is_multi_region_trail = var.is_multi_region_trail

  # Specifies whether the trail is publishing events from global services such as IAM to the log files. Defaults to true.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html#cloudtrail-concepts-global-service-events
  #
  # If other trails are created then they should set include_global_service_events to false in order to avoid duplicate global events
  include_global_service_events = true

  # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
  enable_logging = var.enable_cloudtrail

  # Specifies whether log file integrity validation is enabled. Defaults to false.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html
  #
  # To determine whether a log file was modified, deleted, or unchanged after CloudTrail delivered it, you can use CloudTrail log file integrity validation.
  # This feature is built using industry standard algorithms: SHA-256 for hashing and SHA-256 with RSA for digital signing.
  # This makes it computationally infeasible to modify, delete or forge CloudTrail log files without detection.
  # You can use the AWS CLI to validate the files in the location where CloudTrail delivered them.
  # file integrity. See http://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-cli.html
  enable_log_file_validation = true

  # Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/encrypting-cloudtrail-log-files-with-aws-kms.html
  kms_key_id = local.kms_key_arn

  is_organization_trail = var.is_organization_trail

  tags = var.tags

  # Specifies the name of the Amazon SNS topic defined for notification of log file delivery.
  sns_topic_name = var.notify_sns_topic_name

  # Specifies an event selector for enabling data event logging. Please note the CloudTrail limits when configuring these.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/WhatIsCloudTrail-Limits.html
  # Event selectors |	5 per trail	| This limit cannot be increased.
  dynamic "event_selector" {
    for_each = var.enable_data_logging ? ["once"] : []
    content {
      read_write_type           = var.data_logging_read_write_type
      include_management_events = var.data_logging_include_management_events
      dynamic "data_resource" {
        for_each = var.enable_data_logging ? ["once"] : []
        content {
          type   = var.data_logging_resource_type
          values = var.data_logging_resource_values
        }
      }
    }
  }

  # Specifies an insight selector for enabling Insights logging.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-insights-events-with-cloudtrail.html
  dynamic "insight_selector" {
    for_each = var.enable_insight_logging ? var.enable_insight_types : []
    content {
      insight_type = insight_selector.key
    }
  }

  depends_on = [
    module.bucket,
    null_resource.dependency_getter,
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE S3 BUCKET WHERE CLOUDTRAIL LOGS WILL BE STORED
# ----------------------------------------------------------------------------------------------------------------------

module "bucket" {
  // https://www.terraform.io/docs/language/meta-arguments/count.html
  count  = local.create_s3_bucket ? 1 : 0
  source = "../aws-s3-private-cloudtrail"

  bucket_name                             = local.s3_bucket_name
  enable_cloudtrail_bucket_access_logging = var.enable_cloudtrail_bucket_access_logging
  kms_master_key_arn                      = local.kms_key_arn

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days

  force_destroy = var.force_destroy
  dependencies  = var.dependencies

  tags = var.tags
}


# ----------------------------------------------------------------------------------------------------------------------
# GET THE ARN FOR THE KMS KEY
# ----------------------------------------------------------------------------------------------------------------------

data "aws_kms_key" "user_defined" {
  # supports passing in an alias
  key_id = var.kms_key_arn
}
