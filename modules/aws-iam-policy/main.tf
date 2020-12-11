terraform {
  required_version = ">= 0.12"
}

resource "aws_iam_policy" "policy" {
  name        = var.name
  description = var.description
  path        = var.path
  policy      = var.policy
}
