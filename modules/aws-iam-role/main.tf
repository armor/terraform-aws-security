# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN IAM ROLE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 0.12"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

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
  }
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = var.iam_policy_arns
  role       = aws_iam_role.role.id
  policy_arn = each.value
}
