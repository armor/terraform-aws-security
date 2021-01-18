terraform {
  required_version = ">= 0.12.26"
}

locals {
  aws_account_id        = data.aws_caller_identity.current.account_id
  logging_bucket_name   = var.logging_bucket_name != null ? var.logging_bucket_name : format("%v-logs", var.bucket_name)
  logging_bucket_prefix = var.logging_bucket_prefix != null ? var.logging_bucket_prefix : ""
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A PRIVATE BUCKET
# ----------------------------------------------------------------------------------------------------------------------

#tfsec:ignore:AWS002 logging is enabled by default.  It is inside of a 'dynamic' block.
resource "aws_s3_bucket" "private_s3" {
  bucket = var.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = var.tags

  versioning {
    enabled = var.versioning_enabled
    // mfa_delete can not currently be set from terraform
    // see https://github.com/hashicorp/terraform/issues/12973
    // see https://github.com/hashicorp/terraform-plugin-sdk/issues/238
    // mfa_delete = var.versioning_enabled && var.versioning_with_mfa_delete
  }

  dynamic "logging" {
    for_each = var.logging_enabled ? ["logging"] : []

    content {
      target_bucket = local.logging_bucket_name
      target_prefix = local.logging_bucket_prefix
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A BUCKET TO TARGET S3 LOGGING
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "private_s3_logs" {
  # only create this buket if logging_bucket_name is not specified
  count = signum((var.logging_enabled ? 1 : 0) - try(length(var.logging_bucket_name), 0)) > 0 ? 1 : 0

  bucket = local.logging_bucket_name
  acl    = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = var.tags

  force_destroy = var.force_destroy
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A BUCKET PUBLIC ACCESS BLOCK
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "private_access" {
  bucket = aws_s3_bucket.private_s3.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A BUCKET POLICY
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "private_policy" {
  # use the bucket id from the aws_s3_bucket_public_access_block otherwise we will receive due to a race
  # Error: Error putting S3 policy: OperationAborted: A conflicting conditional operation is currently in progress against this resource.
  bucket = aws_s3_bucket_public_access_block.private_access.id
  policy = data.aws_iam_policy_document.private_policy.json

  depends_on = [
    aws_s3_bucket.private_s3,
    aws_s3_bucket_public_access_block.private_access,
  ]
}

data "aws_iam_policy_document" "private_policy" {

  # source_json is the base of the policy
  # any statements after source_json will overwrite statements passed in via var.policy_json that have the same sid
  # if a statement passed in via var.policy_json does not have a sid then it can not be overwritten
  source_json = var.policy_json

  # ALWAYS REQUIRE TLS IN ORDER TO ACCESS THIS BUCKET
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
  # this statement can not be avoided with any statements in var.policy_json
  statement {
    sid    = "DenyNonTLS"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    not_actions = []

    # Explict deny policy overrides any allow when resources are specified
    resources = [
      aws_s3_bucket.private_s3.arn,
      format("%s/*", aws_s3_bucket.private_s3.arn)
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.allow_s3_integration_services ? ["allow_s3_integration_services"] : []

    content {
      sid    = "AllowS3IntegrationServices"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
      }

      actions = [
        "s3:PutObject"
      ]

      resources = [
        join(":", ["arn", data.aws_partition.current.partition, "s3", "", "", join("/", [var.bucket_name, "*"])])
      ]

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = [
          join(":", ["arn", data.aws_partition.current.partition, "s3", "", "", var.bucket_name])
        ]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values = [
          data.aws_caller_identity.current.account_id
        ]
      }

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values = [
          "bucket-owner-full-control"
        ]
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# GET THE CURRENT AWS CALLER IDENTITY
# ----------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {
}
