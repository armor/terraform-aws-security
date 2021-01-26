terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.22.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  // using distinct for aws_account_ids to keep the ordering. toset will perform both an sort and a distinct
  aws_account_ids    = distinct(concat([data.aws_caller_identity.current.account_id], var.aws_account_ids))
  name               = format("example-%s", var.name)
  kms_master_key_arn = module.aws_kms_master_key.key_arn

  create_s3_bucket = var.create_s3_bucket
  s3_bucket_name   = var.s3_bucket_name

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days
}

module "aws_cloudtrail" {
  source = "../../modules/aws-cloudtrail"

  name                  = local.name
  kms_key_arn           = local.kms_master_key_arn
  force_destroy         = true
  enable_data_logging   = true
  is_organization_trail = false
  create_s3_bucket      = local.create_s3_bucket
  s3_bucket_name        = local.s3_bucket_name
  worm_mode             = local.worm_mode
  worm_retention_days   = local.worm_retention_days
}

module "aws_kms_master_key" {
  source = "../../modules/aws-kms-master-key"

  name                    = local.name
  deletion_window_in_days = 7

  policy_document_override_json = data.aws_iam_policy_document.cloudtrail_policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_policy" {
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

  statement {
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
      values   = [data.aws_organizations_organization.current.id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = formatlist("arn:aws:cloudtrail:*:%s:trail/%s", local.aws_account_ids, local.name)
    }
  }
}

data "aws_caller_identity" "current" {
}

data "aws_organizations_organization" "current" {
}
