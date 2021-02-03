variable "name" {
  description = "The name of the IAM role."
  type        = string
}

variable "path" {
  description = "Path in which to create the policy. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/Using_Identifiers.html) for more information."
  type        = string
  default     = "/"
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

variable "assume_role" {
  description = "Adds the policy action to include `sts:AssumeRole`."
  type        = bool
  default     = true
}

variable "assume_role_with_saml" {
  description = "Adds the policy action to include `sts:AssumeRoleWithSAML`."
  type        = bool
  default     = false
}

variable "assume_role_with_web_identity" {
  description = "Adds the policy action to include `sts:AssumeRoleWithWebIdentity`."
  type        = bool
  default     = false
}

variable "require_mfa" {
  type        = bool
  description = "Include a condition to require `aws:MultiFactorAutoPresent` to be set to `true`."
  default     = true
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
