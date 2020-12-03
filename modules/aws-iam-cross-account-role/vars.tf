variable "name" {
  description = "The name of the IAM role."
  type        = string
}

variable "remote_account_number" {
  description = "The AWS account number of the account permitted to assume this role."
  type        = string
}

variable "iam_policy_arns" {
  description = "The ARNs of IAM policies to attach to this role."
  type        = set(string)
  default     = []
}
