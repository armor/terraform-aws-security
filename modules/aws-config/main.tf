terraform {
  required_version = ">= 0.12.26"
}

locals {
  s3_bucket_name        = format("%s-aws-config-%s", var.name, "s3-bucket")
  s3_bucket_policy_name = format("%s-aws-config-%s", var.name, "s3-bucket-policy")
  role_name             = format("%s-aws-config-%s", var.name, "role")
  recorder_name         = format("%s-aws-config-%s", var.name, "recorder")
  delivery_name         = format("%s-aws-config-%s", var.name, "delivery")
}

// We create an S3 bucket to store AWS Config data
module "s3_private" {
  source             = "../aws-s3-private"
  bucket_name        = local.s3_bucket_name
  versioning_enabled = true
  force_destroy      = true
}

// We create a role for AWS Config to assume
resource "aws_iam_role" "aws_config_role" {
  name = local.role_name
  //  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "config.amazonaws.com"
        }
      },
    ]
  })
}

// AWS Config requires 2 IAM policies to work
// The first is the read-write policy to our S3
resource "aws_iam_role_policy" "s3_bucket_write_policy" {
  name = local.s3_bucket_policy_name
  role = aws_iam_role.aws_config_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "s3:*"
        ],
        Resource : [
          module.s3_private.arn,
          "${module.s3_private.arn}/*"
        ]
      }
    ]
  })
}

// The second is the managed policy (for AWS Config)
resource "aws_iam_role_policy_attachment" "policy" {
  role       = aws_iam_role.aws_config_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

// We optionally accept an SNS topic. We create the IAM policy to write to it.
resource "aws_iam_role_policy" "sns_publish_policy" {

  count = var.sns_topic_arn == null ? 0 : 1

  name = local.s3_bucket_policy_name
  role = aws_iam_role.aws_config_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : "sns:Publish",
        Resource : var.sns_topic_arn
      }
    ]
  })
}

// AWS Config consists 3 Terraform resources. A recorder:
resource "aws_config_configuration_recorder" "recorder" {
  name     = local.recorder_name
  role_arn = aws_iam_role.aws_config_role.arn
}

// A delivery channel: to deliver to the S3, and optionally, an SNS channel
resource "aws_config_delivery_channel" "delivery" {
  name           = local.delivery_name
  s3_bucket_name = local.s3_bucket_name
  sns_topic_arn  = var.sns_topic_arn
  depends_on     = [aws_config_configuration_recorder.recorder]
}

// A status "switch": for turning AWS Config on and off
resource "aws_config_configuration_recorder_status" "configuration_recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = var.enable_aws_config
  depends_on = [aws_config_delivery_channel.delivery]
}

resource "aws_config_config_rule" "access_keys_rotated" {
  name = "access_keys_rotated"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  input_parameters = jsonencode({
    maxAccessKeyAge : 90
  })

  maximum_execution_frequency = "TwentyFour_Hours"

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "vpc_sg_open_only_to_authorized_ports" {
  name = "vpc_sg_open_only_to_authorized_ports"

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }

  maximum_execution_frequency = null

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "dynamodb_table_encryption_enabled" {
  name = "dynamodb_table_encryption_enabled"

  source {
    owner             = "AWS"
    source_identifier = "DYNAMODB_TABLE_ENCRYPTION_ENABLED"
  }

  maximum_execution_frequency = null

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "guardduty_enabled_centralized" {
  name = "guardduty_enabled_centralized"

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }

  maximum_execution_frequency = "TwentyFour_Hours"

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_account_level_public_access_blocks" {
  name = "s3_account_level_public_access_blocks"

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }

  maximum_execution_frequency = null

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3_bucket_public_read_prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  maximum_execution_frequency = null

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "s3_bucket_public_write_prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  maximum_execution_frequency = null

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name = "root_account_mfa_enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  maximum_execution_frequency = "TwentyFour_Hours"

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam_password_policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters : var.require_uppercase_characters
    RequireLowercaseCharacters : var.require_lowercase_characters
    RequireSymbols : var.require_symbols
    RequireNumbers : var.require_numbers
    MinimumPasswordLength : var.minimum_password_length
    PasswordReusePrevention : var.password_reuse_prevention
    MaxPasswordAge : var.max_password_age
  })

  maximum_execution_frequency = "TwentyFour_Hours"

  depends_on = [aws_config_configuration_recorder.recorder]
}
