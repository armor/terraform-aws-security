terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.49.0"
    }
  }
}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_account_ids = concat([local.aws_account_id], var.aws_account_ids)
  bucket_name     = format("cloudtrail-%s%s", data.aws_caller_identity.current.account_id, (var.bucket_name != null ? "-${var.bucket_name}" : ""))

  // local.bucket_key_prefix will either be an empty string or the value of `var.bucket_key_prefix` with a trailing /
  bucket_key_prefix = var.bucket_key_prefix == null ? "" : trim(var.bucket_key_prefix, "/") != "" ? "${trim(var.bucket_key_prefix, "/")}/" : ""

  organization_id       = var.organization_id
  is_organization_trail = local.organization_id != null

  // sse_algorithm will always be set to a value, providing encryption at rest regardless of encryption key use.  AES256 will lead to default SSE-S3 encryption.
  sse_algorithm = var.kms_master_key_arn == null || length(var.kms_master_key_arn) == 0 ? "AES256" : "aws:kms"
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A PRIVATE CLOUDTRAIL BUCKET
# ----------------------------------------------------------------------------------------------------------------------

module "s3_private" {
  source                = "../aws-s3-private"
  bucket_name           = local.bucket_name
  force_destroy         = var.force_destroy
  kms_master_key_arn    = var.kms_master_key_arn
  sse_algorithm         = local.sse_algorithm
  logging_enabled       = var.enable_cloudtrail_bucket_access_logging
  logging_bucket_name   = var.access_logging_bucket_name
  logging_bucket_prefix = var.access_logging_bucket_prefix
  tags                  = var.tags
  versioning_enabled    = true

  policy_json = data.aws_iam_policy_document.cloudtrail_policy.json

  object_lock_configuration = {
    mode = var.worm_mode
    days = var.worm_retention_days
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-set-bucket-policy-for-multiple-accounts.html
# CREATE A BUCKET POLICY SUPPORTING MULTIPLE ACCOUNTS
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "cloudtrail_policy" {

  # source_json is the base of the policy
  # any statements after source_json will overwrite statements passed in via var.policy_json that have the same sid
  # if a statement passed in via var.policy_json does not have a sid then it can not be overwritten
  source_json = var.policy_json

  statement {
    sid    = "AWSCloudTrailAclCheck20131101"
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    not_actions = []

    # Explict deny policy overrides any allow when resources are specified
    resources = [
      join(":", ["arn", "aws", "s3", "", "", local.bucket_name])
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite20131101"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    # organization management account or non-organization trails are logged to:
    # arn:aws:s3:::myBucketName/[optional] myLogFilePrefix/AWSLogs/111111111111/*"
    # organization members are logged to:
    # arn:aws:s3:::myBucketName/AWSLogs/o-abcdefghij/111111111111/*"
    # union the set with the optional organizational member trail accounts
    # passing var.aws_account_ids as ["*"] will permit cloudtrail from any account to write to the bucket
    resources = setunion(
      formatlist("arn:aws:s3:::%s/%sAWSLogs/%s/*", local.bucket_name, local.bucket_key_prefix, local.aws_account_ids),
      local.is_organization_trail ? formatlist("arn:aws:s3:::%s/AWSLogs/%s/%s/*", local.bucket_name, local.organization_id, local.aws_account_ids) : [],
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# GET THE CURRENT AWS CALLER IDENTITY
# ----------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {
}
