variable "name" {
  description = "The IAM user's name. This may only contain alphanumeric characters and any of these special characters: `=,.@-_`."
  type        = string
}

variable "path" {
  description = "The path in which to create the IAM user."
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile, or MFA devices."
  type        = string
  default     = true
}

variable "permissions_boundary_policy_arn" {
  description = "The ARN of the IAM policy representing the most permissions this user may obtain."
  type        = string
  default     = null
}

variable "attached_policy_arns" {
  description = "A list of ARNs of IAM policies that should be directly attached to this user."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "A key-value map of tags for this IAM user."
  type        = map(string)
  default     = {}
}
