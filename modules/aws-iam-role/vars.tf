variable "name" {
  description = "The name of the IAM role."
  type        = string
}

variable "service_principals" {
  description = "A list service principals permitted to assume this role."
  type        = set(string)
  default     = []
}

variable "aws_principals" {
  description = "A list of AWS principals (ARNs) permitted to assume this role."
  type        = set(string)
  default     = []
}

variable "federated_principals" {
  description = "A list of federated principals permitted to assume this role."
  type        = set(string)
  default     = []
}

variable "iam_policy_arns" {
  description = "The ARNs of IAM policies to attach to this role."
  type        = set(string)
  default     = []
}
