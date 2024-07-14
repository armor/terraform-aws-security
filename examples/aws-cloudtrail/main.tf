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
  // using distinct for aws_account_ids to keep the ordering. toset will perform both an sort and a distinct
  aws_account_ids = distinct(concat([data.aws_caller_identity.current.account_id], var.aws_account_ids))
  name            = format("example-%s", var.name)

  create_cloudtrail = true
  create_s3_bucket  = var.create_s3_bucket
  s3_bucket_name    = var.s3_bucket_name

  worm_mode           = var.worm_mode
  worm_retention_days = var.worm_retention_days
  default_tags = {
    managed_by = "terraform"
    module     = "armor/terraform-aws-security/examples/aws-cloudtrail"
  }
  tags = merge(local.default_tags, var.tags)

  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

module "aws_kms_master_key" {
  source = "../../modules/aws-kms-master-key"

  name                     = "${var.name}_kms_master_key"
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  key_usage                = var.key_usage
  tags                     = var.tags
  service_principal_policy_statements = {

    "EncryptCloudwatchSnsTopic" : {
      actions : [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]

      service : "logs.${var.aws_region}.amazonaws.com"

      conditions : []
    }
  }
}

module "aws_cloudtrail_monitoring" {
  source                    = "../../modules/aws-cloudtrail-monitoring"
  cloudwatch_log_group_name = "${var.name}_cloudwatch_log_group"
  kms_master_key_id         = module.aws_kms_master_key.key_arn
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

  aws_region     = local.aws_region
  aws_account_id = local.aws_account_id

  cloudwatch_log_group_arn = module.aws_cloudtrail_monitoring.cloudwatch_log_group_arn
  cloudwatch_logs_role_arn = module.aws_cloudtrail_monitoring.cloudwatch_role_arn
}


data "aws_caller_identity" "current" {
}
