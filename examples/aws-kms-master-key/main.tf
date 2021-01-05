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
  region = "ap-southeast-1"
}

module "aws_kms_master_key" {
  source = "../../modules/aws-kms-master-key"

  name                     = var.name
  service_principals       = var.service_principals
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  tags                     = var.tags
}
