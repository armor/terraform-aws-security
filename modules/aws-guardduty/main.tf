# TODO: AWS Guardduty has a new feature that can monitor S3 buckets, currently it is not yet available thru Terraform
# Link 1: https://github.com/hashicorp/terraform-provider-aws/issues/15106
# Link 2: https://github.com/hashicorp/terraform-provider-aws/pull/15241

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A GUARDDUTY
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.14.6"
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP IPSET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "ipset" {
  count                  = var.create_detector && var.ipset_iplist != null ? 1 : 0
  acl                    = "public-read"
  content                = var.ipset_iplist
  bucket                 = var.bucket_name
  key                    = var.ipset_filename
  etag                   = md5(var.ipset_iplist)
  server_side_encryption = "aws:kms"
}

# ----------------------------------------------------------------------------------------------------------------------
# SETUP THREAT INTEL SET
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_object" "threatintelset" {
  for_each               = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if threat_intel_set.content != null && var.create_detector }
  acl                    = "public-read"
  content                = each.value.content
  bucket                 = var.bucket_name
  key                    = each.value.filename
  etag                   = md5(each.value.content)
  server_side_encryption = "aws:kms"
}

# ----------------------------------------------------------------------------------------------------------------------
# US EAST (N. VIRGINIA)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

resource "aws_guardduty_detector" "useast1" {
  count    = var.create_detector && contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider = aws.useast1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "useast1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider = aws.useast1
}

resource "aws_guardduty_organization_admin_account" "useast1" {
  count            = var.delegate_admin && contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider         = aws.useast1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "useast1" {
  count       = var.auto_enable && contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider    = aws.useast1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.useast1[0].id : data.aws_guardduty_detector.useast1[0].id
}

resource "aws_guardduty_member" "useast1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "us-east-1") ? var.member_list : {}
  provider = aws.useast1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.useast1[0].id : data.aws_guardduty_detector.useast1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "useast1" {
  count       = contains(var.aws_regions, "us-east-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.useast1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast1[0].id : data.aws_guardduty_detector.useast1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "useast1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-east-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.useast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast1[0].id : data.aws_guardduty_detector.useast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "useast1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-east-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.useast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast1[0].id : data.aws_guardduty_detector.useast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# US EAST (OHIO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "useast2"
  region = "us-east-2"
}

resource "aws_guardduty_detector" "useast2" {
  count    = var.create_detector && contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider = aws.useast2
  enable   = var.create_detector
}

data "aws_guardduty_detector" "useast2" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider = aws.useast2
}

resource "aws_guardduty_organization_admin_account" "useast2" {
  count            = var.delegate_admin && contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider         = aws.useast2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "useast2" {
  count       = var.auto_enable && contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider    = aws.useast2
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.useast2[0].id : data.aws_guardduty_detector.useast2[0].id
}

resource "aws_guardduty_member" "useast2" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "us-east-2") ? var.member_list : {}
  provider = aws.useast2

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.useast2[0].id : data.aws_guardduty_detector.useast2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "useast2" {
  count       = contains(var.aws_regions, "us-east-2") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.useast2
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast2[0].id : data.aws_guardduty_detector.useast2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "useast2_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-east-2") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.useast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast2[0].id : data.aws_guardduty_detector.useast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "useast2" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-east-2") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.useast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.useast2[0].id : data.aws_guardduty_detector.useast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# US WEST (N. CALIFORNIA)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "uswest1"
  region = "us-west-1"
}

resource "aws_guardduty_detector" "uswest1" {
  count    = var.create_detector && contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider = aws.uswest1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "uswest1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider = aws.uswest1
}

resource "aws_guardduty_organization_admin_account" "uswest1" {
  count            = var.delegate_admin && contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider         = aws.uswest1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "uswest1" {
  count       = var.auto_enable && contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider    = aws.uswest1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.uswest1[0].id : data.aws_guardduty_detector.uswest1[0].id
}

resource "aws_guardduty_member" "uswest1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "us-west-1") ? var.member_list : {}
  provider = aws.uswest1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.uswest1[0].id : data.aws_guardduty_detector.uswest1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "uswest1" {
  count       = contains(var.aws_regions, "us-west-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.uswest1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest1[0].id : data.aws_guardduty_detector.uswest1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "uswest1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-west-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.uswest1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest1[0].id : data.aws_guardduty_detector.uswest1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "uswest1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-west-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.uswest1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest1[0].id : data.aws_guardduty_detector.uswest1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# US WEST (OREGON)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "uswest2"
  region = "us-west-2"
}

resource "aws_guardduty_detector" "uswest2" {
  count    = var.create_detector && contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider = aws.uswest2
  enable   = var.create_detector
}

data "aws_guardduty_detector" "uswest2" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider = aws.uswest2
}

resource "aws_guardduty_organization_admin_account" "uswest2" {
  count            = var.delegate_admin && contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider         = aws.uswest2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "uswest2" {
  count       = var.auto_enable && contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider    = aws.uswest2
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.uswest2[0].id : data.aws_guardduty_detector.uswest2[0].id
}

resource "aws_guardduty_member" "uswest2" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "us-west-2") ? var.member_list : {}
  provider = aws.uswest2

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.uswest2[0].id : data.aws_guardduty_detector.uswest2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "uswest2" {
  count       = contains(var.aws_regions, "us-west-2") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.uswest2
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest2[0].id : data.aws_guardduty_detector.uswest2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "uswest2_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-west-2") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.uswest2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest2[0].id : data.aws_guardduty_detector.uswest2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "uswest2" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "us-west-2") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.uswest2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.uswest2[0].id : data.aws_guardduty_detector.uswest2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# CANADA (CENTRAL)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "cacentral1"
  region = "ca-central-1"
}

resource "aws_guardduty_detector" "cacentral1" {
  count    = var.create_detector && contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider = aws.cacentral1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "cacentral1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider = aws.cacentral1
}

resource "aws_guardduty_organization_admin_account" "cacentral1" {
  count            = var.delegate_admin && contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider         = aws.cacentral1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "cacentral1" {
  count       = var.auto_enable && contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider    = aws.cacentral1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.cacentral1[0].id : data.aws_guardduty_detector.cacentral1[0].id
}

resource "aws_guardduty_member" "cacentral1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ca-central-1") ? var.member_list : {}
  provider = aws.cacentral1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.cacentral1[0].id : data.aws_guardduty_detector.cacentral1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "cacentral1" {
  count       = contains(var.aws_regions, "ca-central-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.cacentral1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.cacentral1[0].id : data.aws_guardduty_detector.cacentral1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "cacentral1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ca-central-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.cacentral1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.cacentral1[0].id : data.aws_guardduty_detector.cacentral1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "cacentral1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ca-central-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.cacentral1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.cacentral1[0].id : data.aws_guardduty_detector.cacentral1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (FRANKFURT)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eucentral1"
  region = "eu-central-1"
}

resource "aws_guardduty_detector" "eucentral1" {
  count    = var.create_detector && contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider = aws.eucentral1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "eucentral1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider = aws.eucentral1
}

resource "aws_guardduty_organization_admin_account" "eucentral1" {
  count            = var.delegate_admin && contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider         = aws.eucentral1
  admin_account_id = var.aws_account_id
}


resource "aws_guardduty_organization_configuration" "eucentral1" {
  count       = var.auto_enable && contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider    = aws.eucentral1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.eucentral1[0].id : data.aws_guardduty_detector.eucentral1[0].id
}

resource "aws_guardduty_member" "eucentral1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "eu-central-1") ? var.member_list : {}
  provider = aws.eucentral1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.eucentral1[0].id : data.aws_guardduty_detector.eucentral1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eucentral1" {
  count       = contains(var.aws_regions, "eu-central-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.eucentral1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.eucentral1[0].id : data.aws_guardduty_detector.eucentral1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "eucentral1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-central-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.eucentral1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.eucentral1[0].id : data.aws_guardduty_detector.eucentral1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "eucentral1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-central-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.eucentral1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.eucentral1[0].id : data.aws_guardduty_detector.eucentral1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (IRELAND)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "euwest1"
  region = "eu-west-1"
}

resource "aws_guardduty_detector" "euwest1" {
  count    = var.create_detector && contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider = aws.euwest1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "euwest1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider = aws.euwest1
}

resource "aws_guardduty_organization_admin_account" "euwest1" {
  count            = var.delegate_admin && contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider         = aws.euwest1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "euwest1" {
  count       = var.auto_enable && contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider    = aws.euwest1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.euwest1[0].id : data.aws_guardduty_detector.euwest1[0].id
}

resource "aws_guardduty_member" "euwest1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "eu-west-1") ? var.member_list : {}
  provider = aws.euwest1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.euwest1[0].id : data.aws_guardduty_detector.euwest1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "euwest1" {
  count       = contains(var.aws_regions, "eu-west-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.euwest1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest1[0].id : data.aws_guardduty_detector.euwest1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "euwest1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.euwest1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest1[0].id : data.aws_guardduty_detector.euwest1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "euwest1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.euwest1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest1[0].id : data.aws_guardduty_detector.euwest1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (LONDON)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "euwest2"
  region = "eu-west-2"
}

resource "aws_guardduty_detector" "euwest2" {
  count    = var.create_detector && contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider = aws.euwest2
  enable   = var.create_detector
}

data "aws_guardduty_detector" "euwest2" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider = aws.euwest2
}

resource "aws_guardduty_organization_admin_account" "euwest2" {
  count            = var.delegate_admin && contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider         = aws.euwest2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "euwest2" {
  count       = var.auto_enable && contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider    = aws.euwest2
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.euwest2[0].id : data.aws_guardduty_detector.euwest2[0].id
}

resource "aws_guardduty_member" "euwest2" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "eu-west-2") ? var.member_list : {}
  provider = aws.euwest2

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.euwest2[0].id : data.aws_guardduty_detector.euwest2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "euwest2" {
  count       = contains(var.aws_regions, "eu-west-2") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.euwest2
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest2[0].id : data.aws_guardduty_detector.euwest2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "euwest2_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-2") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.euwest2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest2[0].id : data.aws_guardduty_detector.euwest2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "euwest2" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-2") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.euwest2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest2[0].id : data.aws_guardduty_detector.euwest2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (PARIS)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "euwest3"
  region = "eu-west-3"
}

resource "aws_guardduty_detector" "euwest3" {
  count    = var.create_detector && contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider = aws.euwest3
  enable   = var.create_detector
}

data "aws_guardduty_detector" "euwest3" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider = aws.euwest3
}

resource "aws_guardduty_organization_admin_account" "euwest3" {
  count            = var.delegate_admin && contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider         = aws.euwest3
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "euwest3" {
  count       = var.auto_enable && contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider    = aws.euwest3
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.euwest3[0].id : data.aws_guardduty_detector.euwest3[0].id
}

resource "aws_guardduty_member" "euwest3" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "eu-west-3") ? var.member_list : {}
  provider = aws.euwest3

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.euwest3[0].id : data.aws_guardduty_detector.euwest3[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "euwest3" {
  count       = contains(var.aws_regions, "eu-west-3") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.euwest3
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest3[0].id : data.aws_guardduty_detector.euwest3[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "euwest3_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-3") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.euwest3
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest3[0].id : data.aws_guardduty_detector.euwest3[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "euwest3" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-west-3") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.euwest3
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.euwest3[0].id : data.aws_guardduty_detector.euwest3[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (STOCKHOLM)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eunorth1"
  region = "eu-north-1"
}

resource "aws_guardduty_detector" "eunorth1" {
  count    = var.create_detector && contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider = aws.eunorth1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "eunorth1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider = aws.eunorth1
}

resource "aws_guardduty_organization_admin_account" "eunorth1" {
  count            = var.delegate_admin && contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider         = aws.eunorth1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "eunorth1" {
  count       = var.auto_enable && contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider    = aws.eunorth1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.eunorth1[0].id : data.aws_guardduty_detector.eunorth1[0].id
}

resource "aws_guardduty_member" "eunorth1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "eu-north-1") ? var.member_list : {}
  provider = aws.eunorth1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.eunorth1[0].id : data.aws_guardduty_detector.eunorth1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eunorth1" {
  count       = contains(var.aws_regions, "eu-north-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.eunorth1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.eunorth1[0].id : data.aws_guardduty_detector.eunorth1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "eunorth1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-north-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.eunorth1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.eunorth1[0].id : data.aws_guardduty_detector.eunorth1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "eunorth1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "eu-north-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.eunorth1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.eunorth1[0].id : data.aws_guardduty_detector.eunorth1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (TOKYO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "apnortheast1"
  region = "ap-northeast-1"
}

resource "aws_guardduty_detector" "apnortheast1" {
  count    = var.create_detector && contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider = aws.apnortheast1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "apnortheast1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider = aws.apnortheast1
}

resource "aws_guardduty_organization_admin_account" "apnortheast1" {
  count            = var.delegate_admin && contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider         = aws.apnortheast1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "apnortheast1" {
  count       = var.auto_enable && contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider    = aws.apnortheast1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast1[0].id : data.aws_guardduty_detector.apnortheast1[0].id
}

resource "aws_guardduty_member" "apnortheast1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ap-northeast-1") ? var.member_list : {}
  provider = aws.apnortheast1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.apnortheast1[0].id : data.aws_guardduty_detector.apnortheast1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "apnortheast1" {
  count       = contains(var.aws_regions, "ap-northeast-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.apnortheast1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast1[0].id : data.aws_guardduty_detector.apnortheast1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "apnortheast1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-northeast-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.apnortheast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast1[0].id : data.aws_guardduty_detector.apnortheast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "apnortheast1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-northeast-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.apnortheast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast1[0].id : data.aws_guardduty_detector.apnortheast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SEOUL)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "apnortheast2"
  region = "ap-northeast-2"
}

resource "aws_guardduty_detector" "apnortheast2" {
  count    = var.create_detector && contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider = aws.apnortheast2
  enable   = var.create_detector
}

data "aws_guardduty_detector" "apnortheast2" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider = aws.apnortheast2
}

resource "aws_guardduty_organization_admin_account" "apnortheast2" {
  count            = var.delegate_admin && contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider         = aws.apnortheast2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "apnortheast2" {
  count       = var.auto_enable && contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider    = aws.apnortheast2
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast2[0].id : data.aws_guardduty_detector.apnortheast2[0].id
}

resource "aws_guardduty_member" "apnortheast2" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ap-northeast-2") ? var.member_list : {}
  provider = aws.apnortheast2

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.apnortheast2[0].id : data.aws_guardduty_detector.apnortheast2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "apnortheast2" {
  count       = contains(var.aws_regions, "ap-northeast-2") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.apnortheast2
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast2[0].id : data.aws_guardduty_detector.apnortheast2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "apnortheast2_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-northeast-2") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.apnortheast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast2[0].id : data.aws_guardduty_detector.apnortheast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "apnortheast2" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-northeast-2") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.apnortheast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apnortheast2[0].id : data.aws_guardduty_detector.apnortheast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SINGAPORE)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "apsoutheast1"
  region = "ap-southeast-1"
}

resource "aws_guardduty_detector" "apsoutheast1" {
  count    = var.create_detector && contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider = aws.apsoutheast1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "apsoutheast1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider = aws.apsoutheast1
}

resource "aws_guardduty_organization_admin_account" "apsoutheast1" {
  count            = var.delegate_admin && contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider         = aws.apsoutheast1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "apsoutheast1" {
  count       = var.auto_enable && contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider    = aws.apsoutheast1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast1[0].id : data.aws_guardduty_detector.apsoutheast1[0].id
}

resource "aws_guardduty_member" "apsoutheast1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ap-southeast-1") ? var.member_list : {}
  provider = aws.apsoutheast1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.apsoutheast1[0].id : data.aws_guardduty_detector.apsoutheast1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "apsoutheast1" {
  count       = contains(var.aws_regions, "ap-southeast-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.apsoutheast1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast1[0].id : data.aws_guardduty_detector.apsoutheast1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "apsoutheast1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-southeast-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.apsoutheast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast1[0].id : data.aws_guardduty_detector.apsoutheast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "apsoutheast1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-southeast-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.apsoutheast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast1[0].id : data.aws_guardduty_detector.apsoutheast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SYDNEY)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "apsoutheast2"
  region = "ap-southeast-2"
}

resource "aws_guardduty_detector" "apsoutheast2" {
  count    = var.create_detector && contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider = aws.apsoutheast2
  enable   = var.create_detector
}

data "aws_guardduty_detector" "apsoutheast2" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider = aws.apsoutheast2
}

resource "aws_guardduty_organization_admin_account" "apsoutheast2" {
  count            = var.delegate_admin && contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider         = aws.apsoutheast2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "apsoutheast2" {
  count       = var.auto_enable && contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider    = aws.apsoutheast2
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast2[0].id : data.aws_guardduty_detector.apsoutheast2[0].id
}

resource "aws_guardduty_member" "apsoutheast2" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ap-southeast-2") ? var.member_list : {}
  provider = aws.apsoutheast2

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.apsoutheast2[0].id : data.aws_guardduty_detector.apsoutheast2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "apsoutheast2" {
  count       = contains(var.aws_regions, "ap-southeast-2") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.apsoutheast2
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast2[0].id : data.aws_guardduty_detector.apsoutheast2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "apsoutheast2_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-southeast-2") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.apsoutheast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast2[0].id : data.aws_guardduty_detector.apsoutheast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "apsoutheast2" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-southeast-2") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.apsoutheast2
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsoutheast2[0].id : data.aws_guardduty_detector.apsoutheast2[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (MUMBAI)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "apsouth1"
  region = "ap-south-1"
}

resource "aws_guardduty_detector" "apsouth1" {
  count    = var.create_detector && contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider = aws.apsouth1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "apsouth1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider = aws.apsouth1
}

resource "aws_guardduty_organization_admin_account" "apsouth1" {
  count            = var.delegate_admin && contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider         = aws.apsouth1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "apsouth1" {
  count       = var.auto_enable && contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider    = aws.apsouth1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.apsouth1[0].id : data.aws_guardduty_detector.apsouth1[0].id
}

resource "aws_guardduty_member" "apsouth1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "ap-south-1") ? var.member_list : {}
  provider = aws.apsouth1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.apsouth1[0].id : data.aws_guardduty_detector.apsouth1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "apsouth1" {
  count       = contains(var.aws_regions, "ap-south-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.apsouth1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsouth1[0].id : data.aws_guardduty_detector.apsouth1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "apsouth1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-south-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.apsouth1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsouth1[0].id : data.aws_guardduty_detector.apsouth1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "apsouth1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "ap-south-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.apsouth1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.apsouth1[0].id : data.aws_guardduty_detector.apsouth1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}

# ----------------------------------------------------------------------------------------------------------------------
# SOUTH AMERICA (SÃO PAULO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "saeast1"
  region = "sa-east-1"
}

resource "aws_guardduty_detector" "saeast1" {
  count    = var.create_detector && contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider = aws.saeast1
  enable   = var.create_detector
}

data "aws_guardduty_detector" "saeast1" {
  count    = !var.create_detector && var.auto_enable && contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider = aws.saeast1
}

resource "aws_guardduty_organization_admin_account" "saeast1" {
  count            = var.delegate_admin && contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider         = aws.saeast1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "saeast1" {
  count       = var.auto_enable && contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider    = aws.saeast1
  auto_enable = true
  detector_id = var.create_detector ? aws_guardduty_detector.saeast1[0].id : data.aws_guardduty_detector.saeast1[0].id
}

resource "aws_guardduty_member" "saeast1" {
  for_each = var.invite_member_accounts && contains(var.aws_regions, "sa-east-1") ? var.member_list : {}
  provider = aws.saeast1

  account_id                 = each.key
  detector_id                = var.create_detector ? aws_guardduty_detector.saeast1[0].id : data.aws_guardduty_detector.saeast1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "saeast1" {
  count       = contains(var.aws_regions, "sa-east-1") && var.ipset_iplist != null && var.create_detector ? 1 : 0
  provider    = aws.saeast1
  activate    = var.ipset_activate
  detector_id = var.create_detector ? aws_guardduty_detector.saeast1[0].id : data.aws_guardduty_detector.saeast1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = var.ipset_filename
}

resource "aws_guardduty_threatintelset" "saeast1_ignore_changes" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "sa-east-1") && threat_intel_set.ignore_content == true && var.create_detector }
  provider    = aws.saeast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.saeast1[0].id : data.aws_guardduty_detector.saeast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_guardduty_threatintelset" "saeast1" {
  for_each    = { for threat_intel_set in var.threat_intel_sets : threat_intel_set.name => threat_intel_set if contains(var.aws_regions, "sa-east-1") && threat_intel_set.ignore_content == false && var.create_detector }
  provider    = aws.saeast1
  activate    = each.value.activate
  detector_id = var.create_detector ? aws_guardduty_detector.saeast1[0].id : data.aws_guardduty_detector.saeast1[0].id
  format      = each.value.format
  location    = "s3://${var.bucket_name}/${each.value.filename}"
  name        = each.value.name
}
