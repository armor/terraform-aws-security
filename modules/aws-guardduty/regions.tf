# ----------------------------------------------------------------------------------------------------------------------
# US EAST (N. VIRGINIA)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_guardduty_detector" "us-east-1" {
  count    = contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider = aws.us-east-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "us-east-1" {
  count            = contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider         = aws.us-east-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "us-east-1" {
  depends_on  = [aws_guardduty_organization_admin_account.us-east-1]
  count       = contains(var.aws_regions, "us-east-1") ? 1 : 0
  provider    = aws.us-east-1
  auto_enable = true
  detector_id = aws_guardduty_detector.us-east-1[0].id
}

resource "aws_guardduty_member" "us-east-1" {
  depends_on = [aws_guardduty_organization_admin_account.us-east-1]
  for_each   = contains(var.aws_regions, "us-east-1") ? var.member_list : {}
  provider   = aws.us-east-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.us-east-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "us-east-1" {
  count       = contains(var.aws_regions, "us-east-1") && var.has_ipset ? 1 : 0
  provider    = aws.us-east-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.us-east-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "us-east-1" {
  count       = contains(var.aws_regions, "us-east-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.us-east-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.us-east-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# US EAST (OHIO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

resource "aws_guardduty_detector" "us-east-2" {
  count    = contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider = aws.us-east-2
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "us-east-2" {
  count            = contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider         = aws.us-east-2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "us-east-2" {
  depends_on  = [aws_guardduty_organization_admin_account.us-east-2]
  count       = contains(var.aws_regions, "us-east-2") ? 1 : 0
  provider    = aws.us-east-2
  auto_enable = true
  detector_id = aws_guardduty_detector.us-east-2[0].id
}

resource "aws_guardduty_member" "us-east-2" {
  depends_on = [aws_guardduty_organization_admin_account.us-east-2]
  for_each   = contains(var.aws_regions, "us-east-2") ? var.member_list : {}
  provider   = aws.us-east-2

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.us-east-2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "us-east-2" {
  count       = contains(var.aws_regions, "us-east-2") && var.has_ipset ? 1 : 0
  provider    = aws.us-east-2
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.us-east-2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "us-east-2" {
  count       = contains(var.aws_regions, "us-east-2") && var.has_threatintelset ? 1 : 0
  provider    = aws.us-east-2
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.us-east-2[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# US WEST (N. CALIFORNIA)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

resource "aws_guardduty_detector" "us-west-1" {
  count    = contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider = aws.us-west-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "us-west-1" {
  count            = contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider         = aws.us-west-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "us-west-1" {
  depends_on  = [aws_guardduty_organization_admin_account.us-west-1]
  count       = contains(var.aws_regions, "us-west-1") ? 1 : 0
  provider    = aws.us-west-1
  auto_enable = true
  detector_id = aws_guardduty_detector.us-west-1[0].id
}

resource "aws_guardduty_member" "us-west-1" {
  depends_on = [aws_guardduty_organization_admin_account.us-west-1]
  for_each   = contains(var.aws_regions, "us-west-1") ? var.member_list : {}
  provider   = aws.us-west-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.us-west-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "us-west-1" {
  count       = contains(var.aws_regions, "us-west-1") && var.has_ipset ? 1 : 0
  provider    = aws.us-west-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.us-west-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "us-west-1" {
  count       = contains(var.aws_regions, "us-west-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.us-west-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.us-west-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# US WEST (OREGON)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

resource "aws_guardduty_detector" "us-west-2" {
  count    = contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider = aws.us-west-2
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "us-west-2" {
  count            = contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider         = aws.us-west-2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "us-west-2" {
  depends_on  = [aws_guardduty_organization_admin_account.us-west-2]
  count       = contains(var.aws_regions, "us-west-2") ? 1 : 0
  provider    = aws.us-west-2
  auto_enable = true
  detector_id = aws_guardduty_detector.us-west-2[0].id
}

resource "aws_guardduty_member" "us-west-2" {
  depends_on = [aws_guardduty_organization_admin_account.us-west-2]
  for_each   = contains(var.aws_regions, "us-west-2") ? var.member_list : {}
  provider   = aws.us-west-2

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.us-west-2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "us-west-2" {
  count       = contains(var.aws_regions, "us-west-2") && var.has_ipset ? 1 : 0
  provider    = aws.us-west-2
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.us-west-2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "us-west-2" {
  count       = contains(var.aws_regions, "us-west-2") && var.has_threatintelset ? 1 : 0
  provider    = aws.us-west-2
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.us-west-2[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# CANADA (CENTRAL)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ca-central-1"
  region = "ca-central-1"
}

resource "aws_guardduty_detector" "ca-central-1" {
  count    = contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider = aws.ca-central-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ca-central-1" {
  count            = contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider         = aws.ca-central-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ca-central-1" {
  depends_on  = [aws_guardduty_organization_admin_account.ca-central-1]
  count       = contains(var.aws_regions, "ca-central-1") ? 1 : 0
  provider    = aws.ca-central-1
  auto_enable = true
  detector_id = aws_guardduty_detector.ca-central-1[0].id
}

resource "aws_guardduty_member" "ca-central-1" {
  depends_on = [aws_guardduty_organization_admin_account.ca-central-1]
  for_each   = contains(var.aws_regions, "ca-central-1") ? var.member_list : {}
  provider   = aws.ca-central-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ca-central-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ca-central-1" {
  count       = contains(var.aws_regions, "ca-central-1") && var.has_ipset ? 1 : 0
  provider    = aws.ca-central-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ca-central-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ca-central-1" {
  count       = contains(var.aws_regions, "ca-central-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.ca-central-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ca-central-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (FRANKFURT)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

resource "aws_guardduty_detector" "eu-central-1" {
  count    = contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider = aws.eu-central-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "eu-central-1" {
  count            = contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider         = aws.eu-central-1
  admin_account_id = var.aws_account_id
}


resource "aws_guardduty_organization_configuration" "eu-central-1" {
  depends_on  = [aws_guardduty_organization_admin_account.eu-central-1]
  count       = contains(var.aws_regions, "eu-central-1") ? 1 : 0
  provider    = aws.eu-central-1
  auto_enable = true
  detector_id = aws_guardduty_detector.eu-central-1[0].id
}

resource "aws_guardduty_member" "eu-central-1" {
  depends_on = [aws_guardduty_organization_admin_account.eu-central-1]
  for_each   = contains(var.aws_regions, "eu-central-1") ? var.member_list : {}
  provider   = aws.eu-central-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.eu-central-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eu-central-1" {
  count       = contains(var.aws_regions, "eu-central-1") && var.has_ipset ? 1 : 0
  provider    = aws.eu-central-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.eu-central-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "eu-central-1" {
  count       = contains(var.aws_regions, "eu-central-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.eu-central-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.eu-central-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (IRELAND)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

resource "aws_guardduty_detector" "eu-west-1" {
  count    = contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider = aws.eu-west-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "eu-west-1" {
  count            = contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider         = aws.eu-west-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "eu-west-1" {
  depends_on  = [aws_guardduty_organization_admin_account.eu-west-1]
  count       = contains(var.aws_regions, "eu-west-1") ? 1 : 0
  provider    = aws.eu-west-1
  auto_enable = true
  detector_id = aws_guardduty_detector.eu-west-1[0].id
}

resource "aws_guardduty_member" "eu-west-1" {
  depends_on = [aws_guardduty_organization_admin_account.eu-west-1]
  for_each   = contains(var.aws_regions, "eu-west-1") ? var.member_list : {}
  provider   = aws.eu-west-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.eu-west-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eu-west-1" {
  count       = contains(var.aws_regions, "eu-west-1") && var.has_ipset ? 1 : 0
  provider    = aws.eu-west-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.eu-west-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "eu-west-1" {
  count       = contains(var.aws_regions, "eu-west-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.eu-west-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.eu-west-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (LONDON)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

resource "aws_guardduty_detector" "eu-west-2" {
  count    = contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider = aws.eu-west-2
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "eu-west-2" {
  count            = contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider         = aws.eu-west-2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "eu-west-2" {
  depends_on  = [aws_guardduty_organization_admin_account.eu-west-2]
  count       = contains(var.aws_regions, "eu-west-2") ? 1 : 0
  provider    = aws.eu-west-2
  auto_enable = true
  detector_id = aws_guardduty_detector.eu-west-2[0].id
}

resource "aws_guardduty_member" "eu-west-2" {
  depends_on = [aws_guardduty_organization_admin_account.eu-west-2]
  for_each   = contains(var.aws_regions, "eu-west-2") ? var.member_list : {}
  provider   = aws.eu-west-2

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.eu-west-2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eu-west-2" {
  count       = contains(var.aws_regions, "eu-west-2") && var.has_ipset ? 1 : 0
  provider    = aws.eu-west-2
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.eu-west-2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "eu-west-2" {
  count       = contains(var.aws_regions, "eu-west-2") && var.has_threatintelset ? 1 : 0
  provider    = aws.eu-west-2
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.eu-west-2[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (PARIS)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eu-west-3"
  region = "eu-west-3"
}

resource "aws_guardduty_detector" "eu-west-3" {
  count    = contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider = aws.eu-west-3
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "eu-west-3" {
  count            = contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider         = aws.eu-west-3
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "eu-west-3" {
  depends_on  = [aws_guardduty_organization_admin_account.eu-west-3]
  count       = contains(var.aws_regions, "eu-west-3") ? 1 : 0
  provider    = aws.eu-west-3
  auto_enable = true
  detector_id = aws_guardduty_detector.eu-west-3[0].id
}

resource "aws_guardduty_member" "eu-west-3" {
  depends_on = [aws_guardduty_organization_admin_account.eu-west-3]
  for_each   = contains(var.aws_regions, "eu-west-3") ? var.member_list : {}
  provider   = aws.eu-west-3

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.eu-west-3[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eu-west-3" {
  count       = contains(var.aws_regions, "eu-west-3") && var.has_ipset ? 1 : 0
  provider    = aws.eu-west-3
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.eu-west-3[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "eu-west-3" {
  count       = contains(var.aws_regions, "eu-west-3") && var.has_threatintelset ? 1 : 0
  provider    = aws.eu-west-3
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.eu-west-3[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# EUROPE (STOCKHOLM)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
}

resource "aws_guardduty_detector" "eu-north-1" {
  count    = contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider = aws.eu-north-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "eu-north-1" {
  count            = contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider         = aws.eu-north-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "eu-north-1" {
  depends_on  = [aws_guardduty_organization_admin_account.eu-north-1]
  count       = contains(var.aws_regions, "eu-north-1") ? 1 : 0
  provider    = aws.eu-north-1
  auto_enable = true
  detector_id = aws_guardduty_detector.eu-north-1[0].id
}

resource "aws_guardduty_member" "eu-north-1" {
  depends_on = [aws_guardduty_organization_admin_account.eu-north-1]
  for_each   = contains(var.aws_regions, "eu-north-1") ? var.member_list : {}
  provider   = aws.eu-north-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.eu-north-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "eu-north-1" {
  count       = contains(var.aws_regions, "eu-north-1") && var.has_ipset ? 1 : 0
  provider    = aws.eu-north-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.eu-north-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "eu-north-1" {
  count       = contains(var.aws_regions, "eu-north-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.eu-north-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.eu-north-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (TOKYO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"
}

resource "aws_guardduty_detector" "ap-northeast-1" {
  count    = contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider = aws.ap-northeast-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap-northeast-1" {
  count            = contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider         = aws.ap-northeast-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ap-northeast-1" {
  depends_on  = [aws_guardduty_organization_admin_account.ap-northeast-1]
  count       = contains(var.aws_regions, "ap-northeast-1") ? 1 : 0
  provider    = aws.ap-northeast-1
  auto_enable = true
  detector_id = aws_guardduty_detector.ap-northeast-1[0].id
}

resource "aws_guardduty_member" "ap-northeast-1" {
  depends_on = [aws_guardduty_organization_admin_account.ap-northeast-1]
  for_each   = contains(var.aws_regions, "ap-northeast-1") ? var.member_list : {}
  provider   = aws.ap-northeast-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ap-northeast-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ap-northeast-1" {
  count       = contains(var.aws_regions, "ap-northeast-1") && var.has_ipset ? 1 : 0
  provider    = aws.ap-northeast-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ap-northeast-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ap-northeast-1" {
  count       = contains(var.aws_regions, "ap-northeast-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.ap-northeast-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ap-northeast-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SEOUL)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ap-northeast-2"
  region = "ap-northeast-2"
}

resource "aws_guardduty_detector" "ap-northeast-2" {
  count    = contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider = aws.ap-northeast-2
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap-northeast-2" {
  count            = contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider         = aws.ap-northeast-2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ap-northeast-2" {
  depends_on  = [aws_guardduty_organization_admin_account.ap-northeast-2]
  count       = contains(var.aws_regions, "ap-northeast-2") ? 1 : 0
  provider    = aws.ap-northeast-2
  auto_enable = true
  detector_id = aws_guardduty_detector.ap-northeast-2[0].id
}

resource "aws_guardduty_member" "ap-northeast-2" {
  depends_on = [aws_guardduty_organization_admin_account.ap-northeast-2]
  for_each   = contains(var.aws_regions, "ap-northeast-2") ? var.member_list : {}
  provider   = aws.ap-northeast-2

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ap-northeast-2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ap-northeast-2" {
  count       = contains(var.aws_regions, "ap-northeast-2") && var.has_ipset ? 1 : 0
  provider    = aws.ap-northeast-2
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ap-northeast-2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ap-northeast-2" {
  count       = contains(var.aws_regions, "ap-northeast-2") && var.has_threatintelset ? 1 : 0
  provider    = aws.ap-northeast-2
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ap-northeast-2[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SINGAPORE)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

resource "aws_guardduty_detector" "ap-southeast-1" {
  count    = contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider = aws.ap-southeast-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap-southeast-1" {
  count            = contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider         = aws.ap-southeast-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ap-southeast-1" {
  depends_on  = [aws_guardduty_organization_admin_account.ap-southeast-1]
  count       = contains(var.aws_regions, "ap-southeast-1") ? 1 : 0
  provider    = aws.ap-southeast-1
  auto_enable = true
  detector_id = aws_guardduty_detector.ap-southeast-1[0].id
}

resource "aws_guardduty_member" "ap-southeast-1" {
  depends_on = [aws_guardduty_organization_admin_account.ap-southeast-1]
  for_each   = contains(var.aws_regions, "ap-southeast-1") ? var.member_list : {}
  provider   = aws.ap-southeast-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ap-southeast-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ap-southeast-1" {
  count       = contains(var.aws_regions, "ap-southeast-1") && var.has_ipset ? 1 : 0
  provider    = aws.ap-southeast-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ap-southeast-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ap-southeast-1" {
  count       = contains(var.aws_regions, "ap-southeast-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.ap-southeast-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ap-southeast-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (SYDNEY)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ap-southeast-2"
  region = "ap-southeast-2"
}

resource "aws_guardduty_detector" "ap-southeast-2" {
  count    = contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider = aws.ap-southeast-2
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap-southeast-2" {
  count            = contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider         = aws.ap-southeast-2
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ap-southeast-2" {
  depends_on  = [aws_guardduty_organization_admin_account.ap-southeast-2]
  count       = contains(var.aws_regions, "ap-southeast-2") ? 1 : 0
  provider    = aws.ap-southeast-2
  auto_enable = true
  detector_id = aws_guardduty_detector.ap-southeast-2[0].id
}

resource "aws_guardduty_member" "ap-southeast-2" {
  depends_on = [aws_guardduty_organization_admin_account.ap-southeast-2]
  for_each   = contains(var.aws_regions, "ap-southeast-2") ? var.member_list : {}
  provider   = aws.ap-southeast-2

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ap-southeast-2[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ap-southeast-2" {
  count       = contains(var.aws_regions, "ap-southeast-2") && var.has_ipset ? 1 : 0
  provider    = aws.ap-southeast-2
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ap-southeast-2[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ap-southeast-2" {
  count       = contains(var.aws_regions, "ap-southeast-2") && var.has_threatintelset ? 1 : 0
  provider    = aws.ap-southeast-2
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ap-southeast-2[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# ASIA PACIFIC (MUMBAI)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}

resource "aws_guardduty_detector" "ap-south-1" {
  count    = contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider = aws.ap-south-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap-south-1" {
  count            = contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider         = aws.ap-south-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "ap-south-1" {
  depends_on  = [aws_guardduty_organization_admin_account.ap-south-1]
  count       = contains(var.aws_regions, "ap-south-1") ? 1 : 0
  provider    = aws.ap-south-1
  auto_enable = true
  detector_id = aws_guardduty_detector.ap-south-1[0].id
}

resource "aws_guardduty_member" "ap-south-1" {
  depends_on = [aws_guardduty_organization_admin_account.ap-south-1]
  for_each   = contains(var.aws_regions, "ap-south-1") ? var.member_list : {}
  provider   = aws.ap-south-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.ap-south-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "ap-south-1" {
  count       = contains(var.aws_regions, "ap-south-1") && var.has_ipset ? 1 : 0
  provider    = aws.ap-south-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.ap-south-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "ap-south-1" {
  count       = contains(var.aws_regions, "ap-south-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.ap-south-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.ap-south-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}

# ----------------------------------------------------------------------------------------------------------------------
# SOUTH AMERICA (SÃO PAULO)
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
}

resource "aws_guardduty_detector" "sa-east-1" {
  count    = contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider = aws.sa-east-1
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "sa-east-1" {
  count            = contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider         = aws.sa-east-1
  admin_account_id = var.aws_account_id
}

resource "aws_guardduty_organization_configuration" "sa-east-1" {
  depends_on  = [aws_guardduty_organization_admin_account.sa-east-1]
  count       = contains(var.aws_regions, "sa-east-1") ? 1 : 0
  provider    = aws.sa-east-1
  auto_enable = true
  detector_id = aws_guardduty_detector.sa-east-1[0].id
}

resource "aws_guardduty_member" "sa-east-1" {
  depends_on = [aws_guardduty_organization_admin_account.sa-east-1]
  for_each   = contains(var.aws_regions, "sa-east-1") ? var.member_list : {}
  provider   = aws.sa-east-1

  account_id                 = each.key
  detector_id                = aws_guardduty_detector.sa-east-1[0].id
  email                      = each.value
  disable_email_notification = true
}

resource "aws_guardduty_ipset" "sa-east-1" {
  count       = contains(var.aws_regions, "sa-east-1") && var.has_ipset ? 1 : 0
  provider    = aws.sa-east-1
  activate    = var.ipset_activate
  detector_id = aws_guardduty_detector.sa-east-1[0].id
  format      = var.ipset_format
  location    = "s3://${aws_s3_bucket_object.ipset[0].bucket}/${aws_s3_bucket_object.ipset[0].key}"
  name        = local.ipset_name
}

resource "aws_guardduty_threatintelset" "sa-east-1" {
  count       = contains(var.aws_regions, "sa-east-1") && var.has_threatintelset ? 1 : 0
  provider    = aws.sa-east-1
  activate    = var.threatintelset_activate
  detector_id = aws_guardduty_detector.sa-east-1[0].id
  format      = var.threatintelset_format
  location    = "s3://${aws_s3_bucket_object.threatintelset[0].bucket}/${aws_s3_bucket_object.threatintelset[0].key}"
  name        = local.threatintelset_name
}
