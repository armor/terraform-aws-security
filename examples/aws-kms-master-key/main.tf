terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "cmk"
  region = "us-east-1"
}

module "aws_kms_master_key" {
  source = "../../modules/aws-kms-master-key"

  providers = {
    aws.cmk = aws.cmk
  }

  name                                = var.name
  deletion_window_in_days             = var.deletion_window_in_days
  enable_key_rotation                 = var.enable_key_rotation
  customer_master_key_spec            = var.customer_master_key_spec
  key_usage                           = var.key_usage
  tags                                = var.tags
  service_principal_policy_statements = var.service_principal_policy_statements
}
