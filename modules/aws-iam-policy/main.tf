terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.49.0"
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = var.name
  description = var.description
  path        = var.path
  policy      = var.policy
}
