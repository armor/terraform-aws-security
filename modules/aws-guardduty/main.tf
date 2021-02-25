# ----------------------------------------------------------------------------------------------------------------------
# CREATE A GUARDDUTY
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.14.6"
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  ipset_name          = "IPSet"
  ipset_key           = "ipset.txt"
  threatintelset_name = "ThreatIntelSet"
  threatintelset_key  = "threatintelset.txt"
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP S3 BUCKEET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "security" {
  count = (var.has_ipset || var.has_threatintelset) ? 1 : 0

  bucket_prefix = var.bucket_name
  acl           = "private"

  logging {
    target_bucket = var.logging["target_bucket"]
    target_prefix = var.logging["target_prefix"]
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# DELEGATE GUARDDUTY TO A SECURITY ACCOUNT
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_guardduty_organization_admin_account" "guardduty_account" {
  admin_account_id = var.aws_account_id
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP IPSET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "ipset" {
  count                  = var.has_ipset ? 1 : 0
  acl                    = "public-read"
  content                = var.ipset_iplist
  bucket                 = aws_s3_bucket.security[0].id
  key                    = local.ipset_key
  etag                   = md5(var.ipset_iplist)
  server_side_encryption = "aws:kms"
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP THREAT INTEL SET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "threatintelset" {
  count                  = var.has_threatintelset ? 1 : 0
  acl                    = "public-read"
  content                = var.threatintelset_iplist
  bucket                 = aws_s3_bucket.security[0].id
  key                    = local.threatintelset_key
  etag                   = md5(var.threatintelset_iplist)
  server_side_encryption = "aws:kms"
}
