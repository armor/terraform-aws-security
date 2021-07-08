terraform {
  required_version = ">= 0.13.0"

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


module "aws_cloudtrail_alarms" {
  source = "../../modules/aws-cloudtrail-alarms"

  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  kms_master_key_id         = "--TODO--"
}
