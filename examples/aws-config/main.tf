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

module "example_aws_config" {
  source            = "../../modules/aws-config"
  name              = var.name_prefix
  enable_aws_config = var.enable_aws_config
}
