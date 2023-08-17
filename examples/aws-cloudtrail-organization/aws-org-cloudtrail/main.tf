terraform {
  required_version = ">= 1.2"
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
  #  this_account_id       = data.aws_caller_identity.current.account_id
  #  management_account_id = data.aws_organizations_organization.current.master_account_id
  is_management_account = true

  create_cloudtrail     = true
  create_kms_key        = false
  create_s3_bucket      = false
  is_organization_trail = var.is_organization_trail

  update_aws_service_access_principals = local.is_organization_trail == true && var.update_aws_service_access_principals == true

  // using distinct for aws_account_ids to keep the ordering. toset will perform both an sort and a distinct
  aws_account_ids = flatten([
    local.is_management_account == true
    // if this is the management account then use the aws_organizations_organization data to return the accounts
    ? [for account in data.aws_organizations_organization.current.accounts : account.id]
    // if this is not the management account then use the list of aws account ids that is passed in, including our own
    : distinct(concat([data.aws_caller_identity.current.account_id], var.aws_account_ids))
  ])

  aws_service_access_principals = setunion(["cloudtrail.amazonaws.com"], var.aws_service_access_principals)

  name        = format("example-%s", var.name)
  kms_key_arn = local.create_kms_key == false ? var.kms_key_arn : null

  s3_bucket_name = var.s3_bucket_name

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days

  default_tags = {
    managed_by = "terraform"
    module     = "quantum-sec/package-aws-security/examples/aws-cloudtrail"
  }
  tags = merge(local.default_tags, var.tags)
}

module "aws_cloudtrail" {
  source = "../../../modules/aws-cloudtrail"
  // only create this module if this is the management account
  count = 1 // local.create_cloudtrail || local.create_s3_bucket || local.create_kms_key ? 1 : 0

  create_cloudtrail                   = local.create_cloudtrail
  create_s3_bucket                    = local.create_s3_bucket
  create_dedicated_kms_cloudtrail_key = local.create_kms_key

  name                  = local.name
  kms_key_arn           = local.kms_key_arn
  force_destroy         = true
  enable_data_logging   = true
  is_organization_trail = local.is_organization_trail
  aws_account_ids       = local.aws_account_ids

  s3_bucket_name      = local.s3_bucket_name
  worm_mode           = local.worm_mode
  worm_retention_days = local.worm_retention_days

  tags = local.tags
}

resource "aws_organizations_organization" "org" {
  count = local.update_aws_service_access_principals == true ? 1 : 0

  aws_service_access_principals = local.aws_service_access_principals

  feature_set = "ALL"
}

data "aws_caller_identity" "current" {
}

data "aws_organizations_organization" "current" {
}
