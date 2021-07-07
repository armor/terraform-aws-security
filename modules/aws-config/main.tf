terraform {
  required_version = ">= 0.12.26"
}

locals {
  s3_bucket_name        = format("%s-aws-config-%s", var.name, "s3-bucket")
  s3_bucket_policy_name = format("%s-aws-config-%s", var.name, "s3-bucket-policy")
  role_name             = format("%s-aws-config-%s", var.name, "role")
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


variable "name" {
  description = "This will be prefixed to create the AWS resources. 'example' will create a bucket named 'example-aws-config-s3-bucket'"
  type        = string
}
