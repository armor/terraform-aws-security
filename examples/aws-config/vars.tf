# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region into which this resource is deployed."
  type        = string
  default     = "ap-southeast-1"
}

variable "name_prefix" {
  default = "example"
  type    = string
}

variable "enable_aws_config" {
  default = true
  type    = bool
}
