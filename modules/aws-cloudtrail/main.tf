# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A CLOUDTRAIL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # https://www.terraform.io/docs/language/meta-arguments/count.html
  # Version note: Module support for count was added in Terraform 0.13, and previous versions can only use it with resources.
  required_version = ">= 0.13"
}

locals {
  name = var.name

  create_cloudtrail     = var.create_cloudtrail
  create_kms_key        = var.create_dedicated_kms_cloudtrail_key
  create_s3_bucket      = var.create_s3_bucket
  is_organization_trail = var.is_organization_trail
  organization_id       = local.is_organization_trail == true ? data.aws_organizations_organization.current[0].id : null
  lookup_kms_key        = local.create_kms_key == false && var.kms_key_arn != null

  kms_key_additional_iam_policy = var.kms_key_additional_iam_policy

  aws_account_ids    = distinct(concat([data.aws_caller_identity.current.account_id], var.aws_account_ids))
  s3_key_prefix      = var.s3_key_prefix
  discovered_kms_key = local.lookup_kms_key == true ? data.aws_kms_key.user_defined[0].arn : null
  kms_key_arn        = local.create_kms_key == true ? module.aws_kms_master_key[0].key_arn : local.discovered_kms_key
  kms_key_alias      = local.create_kms_key == true ? module.aws_kms_master_key[0].key_alias : null
  s3_bucket_name     = var.s3_bucket_name != null ? var.s3_bucket_name : local.name
  tags               = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# ENABLE CLOUDTRAIL
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_cloudtrail" "cloudtrail" {
  count = local.create_cloudtrail == true ? 1 : 0
  name  = local.name

  # Specifies the name of the S3 bucket designated for publishing log files.
  s3_bucket_name = local.create_s3_bucket ? module.bucket[0].id : local.s3_bucket_name
  s3_key_prefix  = local.s3_key_prefix

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

  is_organization_trail = local.is_organization_trail

  tags = local.tags

  # Specifies the name of the Amazon SNS topic defined for notification of log file delivery.
  sns_topic_name = var.notify_sns_topic_name

  # Specifies an event selector for enabling data event logging. Please note the CloudTrail limits when configuring these.
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html
  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/WhatIsCloudTrail-Limits.html
  # Event selectors |	5 per trail	| This limit cannot be increased.
  dynamic "event_selector" {
    for_each = var.enable_data_logging ? [1] : []
    content {
      read_write_type           = var.data_logging_read_write_type
      include_management_events = var.data_logging_include_management_events
      dynamic "data_resource" {
        for_each = var.data_resources
        content {
          type   = data_resource.key
          values = data_resource.value
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
    # the conditional module.bucket must be completely satisfied prior to creating the cloudtrail
    module.bucket
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE S3 BUCKET WHERE CLOUDTRAIL LOGS WILL BE STORED
# ----------------------------------------------------------------------------------------------------------------------

module "bucket" {
  // https://www.terraform.io/docs/language/meta-arguments/count.html
  count  = local.create_s3_bucket == true ? 1 : 0
  source = "../aws-s3-private-cloudtrail"

  bucket_name                             = local.s3_bucket_name
  bucket_key_prefix                       = local.s3_key_prefix
  aws_account_ids                         = local.aws_account_ids
  enable_cloudtrail_bucket_access_logging = var.enable_cloudtrail_bucket_access_logging
  kms_master_key_arn                      = local.kms_key_arn
  organization_id                         = local.organization_id

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days

  force_destroy = var.force_destroy

  tags = local.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE CMK
# ----------------------------------------------------------------------------------------------------------------------

module "aws_kms_master_key" {
  count  = local.create_kms_key == true ? 1 : 0
  source = "../aws-kms-master-key"

  name                    = local.name
  deletion_window_in_days = 7

  policy_document_override_json = data.aws_iam_policy_document.kms_cloudtrail_policy[0].json

  tags = local.tags
}

data "aws_iam_policy_document" "kms_cloudtrail_policy" {
  count = local.create_kms_key == true ? 1 : 0

  override_json = local.kms_key_additional_iam_policy

  statement {
    sid    = "AllowServicePrincipalAccess-cloudtrail-Encrypt"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = formatlist("arn:aws:cloudtrail:*:%s:trail/%s", local.aws_account_ids, local.name)
    }
  }

  statement {
    sid    = "AllowServicePrincipalAccess-cloudtrail-Describe"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  # Allow the root account full access to allow IAM-controlled CMK permissions.
  dynamic "statement" {
    for_each = local.is_organization_trail == true ? [data.aws_organizations_organization.current[0].master_account_id] : []
    content {
      sid       = "AllowOrgRootAccountFullAccess"
      effect    = "Allow"
      resources = ["*"]
      actions   = ["kms:*"]

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${statement.value}:root"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = local.is_organization_trail == true ? [data.aws_organizations_organization.current[0].id] : []
    content {
      sid    = "AllowServicePrincipalAccess-cloudtrail-Decrypt"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalOrgID"
        values   = [statement.value]
      }
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:cloudtrail:arn"
        values   = formatlist("arn:aws:cloudtrail:*:%s:trail/%s", local.aws_account_ids, local.name)
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# GET THE ARN FOR THE KMS KEY
# ----------------------------------------------------------------------------------------------------------------------

data "aws_kms_key" "user_defined" {
  count = local.lookup_kms_key == true ? 1 : 0

  # supports passing in an alias
  key_id = var.kms_key_arn
}

# ----------------------------------------------------------------------------------------------------------------------
# GET INFORMATION ABOUT OUR ORGANIZATION
# ----------------------------------------------------------------------------------------------------------------------

data "aws_organizations_organization" "current" {
  count = local.is_organization_trail == true || local.create_kms_key == true ? 1 : 0
}

# ----------------------------------------------------------------------------------------------------------------------
# GET INFORMATION ABOUT OUR CURRENT IDENTITY
# ----------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {
}
