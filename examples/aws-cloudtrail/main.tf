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
  name               = format("example-%s", var.name)
  kms_master_key_arn = module.aws_cloudtrail.kms_key_arn

  create_cloudtrail = true
  create_s3_bucket  = var.create_s3_bucket
  s3_bucket_name    = var.s3_bucket_name

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days
  default_tags = {
    managed_by = "terraform"
    module     = "quantum-sec/package-aws-security/examples/aws-cloudtrail"
  }
  tags = merge(local.default_tags, var.tags)
}

module "aws_cloudtrail" {
  source = "../../modules/aws-cloudtrail"

  name                  = local.name
  aws_account_ids       = local.aws_account_ids
  force_destroy         = true
  enable_data_logging   = true
  is_organization_trail = false
  create_cloudtrail     = local.create_cloudtrail
  create_s3_bucket      = local.create_s3_bucket
  s3_bucket_name        = local.s3_bucket_name
  worm_mode             = local.worm_mode
  worm_retention_days   = local.worm_retention_days
  tags                  = local.tags
}

data "aws_caller_identity" "current" {
}
