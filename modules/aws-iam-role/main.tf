# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN IAM ROLE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 0.12"
}

locals {
  assume_role_actions = setunion(
    var.assume_role ? ["sts:AssumeRole"] : [],
    var.assume_role_with_saml ? ["sts:AssumeRoleWithSAML"] : [],
    var.assume_role_with_web_identity ? ["sts:AssumeRoleWithWebIdentity"] : []
  )
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "AssumeRole${replace(title(replace(var.name, "/[_-]+/", " ")), " ", "")}"
    effect  = "Allow"
    actions = local.assume_role_actions

    dynamic "principals" {
      for_each = length(var.aws_principals) > 0 ? [1] : []

      content {
        type        = "AWS"
        identifiers = var.aws_principals
      }
    }

    dynamic "principals" {
      for_each = length(var.service_principals) > 0 ? [1] : []

      content {
        type        = "Service"
        identifiers = var.service_principals
      }
    }

    dynamic "principals" {
      for_each = length(var.federated_principals) > 0 ? [1] : []

      content {
        type        = "Federated"
        identifiers = var.federated_principals
      }
    }

    dynamic "condition" {
      for_each = var.require_mfa ? [1] : []

      content {
        test     = "Bool"
        values   = ["true"]
        variable = "aws:MultiFactorAuthPresent"
      }
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.name
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = var.iam_policy_arns
  role       = aws_iam_role.role.id
  policy_arn = each.value
}
