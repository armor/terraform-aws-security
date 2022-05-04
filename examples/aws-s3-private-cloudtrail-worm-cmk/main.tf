terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  // using distinct for aws_account_ids to keep the ordering. toset will perform both an sort and a distinct
  aws_account_ids    = distinct(concat([data.aws_caller_identity.current.account_id], var.aws_account_ids))
  name               = format("example-%s-%s", data.aws_caller_identity.current.account_id, var.name)
  kms_master_key_arn = module.aws_kms_master_key.key_arn
}

module "aws_s3_private_cloudtrail" {
  source = "../../modules/aws-s3-private-cloudtrail"

  bucket_name         = local.name
  aws_account_ids     = local.aws_account_ids
  kms_master_key_arn  = local.kms_master_key_arn
  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days

  enable_cloudtrail_bucket_access_logging = var.enable_cloudtrail_bucket_access_logging
  access_logging_bucket_name              = var.logging_bucket_name

  force_destroy = true
  tags          = var.tags
}

module "aws_kms_master_key" {
  source = "../../modules/aws-kms-master-key"

  name                    = local.name
  deletion_window_in_days = 7

  service_principal_policy_statements = {
    "AllowCloudTrailGenerateDataKey" = {
      "service" = "cloudtrail.amazonaws.com",
      "actions" = ["kms:GenerateDataKey*"]
      "conditions" = toset([{
        test     = "StringLike",
        variable = "kms:EncryptionContext:aws:cloudtrail:arn",
        // enumerate a list of ARN's that include each aws account id, including our own, and the trail name
        values = formatlist("arn:aws:cloudtrail:*:%s:trail/%s", local.aws_account_ids, local.name),
      }])
    }
  }

  tags = var.tags
}

data "aws_caller_identity" "current" {
}
