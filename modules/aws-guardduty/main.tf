# ----------------------------------------------------------------------------------------------------------------------
# CREATE A GUARDDUTY
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.14.6"
}

provider "aws" {
  region = var.aws_region
}

locals {
  ipset_name          = "IPSet"
  ipset_key           = "ipset.txt"
  threatintelset_name = "ThreatIntelSet"
  threatintelset_key  = "threatintelset.txt"

  # TFlint has a bug with AWS modules and heredoc, as a workaround you can define the variable inside local
  # https://github.com/terraform-linters/tflint/issues/1029
  policy = <<-TEMPLATE
  {
    "Version": "2012-10-17",
    "Statement":
    [
      {
        "Effect": "Allow",
        "Action": [ "guardduty:*" ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [ "iam:CreateServiceLinkedRole" ],
        "Resource": "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty",
        "Condition": {
          "StringLike": { "iam:AWSServiceName": "guardduty.amazonaws.com" }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy"
        ],
        "Resource": "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"
      }
    ]
  }
  TEMPLATE
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP GUARDDUTY POLICY
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "enable_guardduty" {
  name        = "enable-guardduty-${var.aws_region}"
  path        = "/"
  description = "Allows setup and configuration of GuardDuty"
  policy      = local.policy
}

# ----------------------------------------------------------------------------------------------------------------------
# DELEGATE GUARDDUTY TO A SECURITY ACCOUNT
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_group" "guardduty" {
  name = "${var.group_name}-${var.aws_region}"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "enable" {
  group      = aws_iam_group.guardduty.name
  policy_arn = aws_iam_policy.enable_guardduty.arn
}


resource "aws_iam_group_policy_attachment" "access" {
  group      = aws_iam_group.guardduty.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess"
}

resource "aws_iam_group_membership" "guardduty" {
  name  = "guardduty-admin-members-${var.aws_region}"
  group = aws_iam_group.guardduty.name
  users = var.member_list
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP IPSET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "ipset" {
  count   = var.has_ipset ? 1 : 0
  acl     = "public-read"
  content = var.ipset_iplist
  bucket  = var.bucket_name
  key     = local.ipset_key
}

resource "aws_guardduty_ipset" "ipset" {
  count       = var.has_ipset ? 1 : 0
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.guardduty.id
  format      = var.ipset_format
  location    = "https://s3.amazonaws.com/${var.bucket_name}/${local.ipset_key}"
  name        = local.ipset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP THREAT INTEL SET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "threatintelset" {
  count   = var.has_threatintelset ? 1 : 0
  acl     = "public-read"
  content = var.threatintelset_iplist
  bucket  = var.bucket_name
  key     = local.threatintelset_key
}

resource "aws_guardduty_threatintelset" "threatintelset" {
  count       = var.has_threatintelset ? 1 : 0
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.guardduty.id
  format      = var.threatintelset_format
  location    = "https://s3.amazonaws.com/${var.bucket_name}/${local.threatintelset_key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ENABLE GUARDDUTY
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_guardduty_detector" "guardduty" {
  enable = var.detector_enable
}
