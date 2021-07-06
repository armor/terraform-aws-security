terraform {
  required_version = ">= 0.12.26"
}

locals {
  s3_bucket_name = format("%s-aws-config-%s", var.name, "s3-bucket")
}

// We create an S3 bucket to store AWS Config data
module "s3_private" {
  source             = "../aws-s3-private"
  bucket_name        = local.s3_bucket_name
  versioning_enabled = true
  force_destroy      = true
}

variable "name" {
  description = "This will be prefixed to create the AWS resources. 'example' will create a bucket named 'example-aws-config-s3-bucket'"
  type        = string
}
