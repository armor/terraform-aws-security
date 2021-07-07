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
          "${module.s3_private.arn}",
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

// AWS Config consists 3 Terraform resources. A recorder:
resource "aws_config_configuration_recorder" "recorder" {
  name     = local.recorder_name
  role_arn = aws_iam_role.aws_config_role.arn
}

// A delivery channel: to deliver to the S3, and optionally, an SNS channel
resource "aws_config_delivery_channel" "delivery" {
  name           = local.delivery_name
  s3_bucket_name = local.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.recorder]
}

// A status "switch": for turning AWS Config on and off
resource "aws_config_configuration_recorder_status" "foo" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = var.enable_aws_config
  depends_on = [aws_config_delivery_channel.delivery]
}

variable "name" {
  description = "This will be prefixed to create the AWS resources. 'example' will create a bucket named 'example-aws-config-s3-bucket'"
  type        = string
}

variable "enable_aws_config" {
  description = "Boolean toggle to turn of and off the AWS Config recording"
  type        = bool
}
