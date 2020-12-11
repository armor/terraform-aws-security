variable "name" {
  description = "The name of the IAM policy."
  type        = string
}

variable "description" {
  description = "The description of the IAM policy."
  type        = string
  default     = null
}

variable "path" {
  description = "The path in which to create the IAM policy."
  type        = string
  default     = "/"
}

variable "policy" {
  description = "The policy document as a JSON formatted string."
  type        = string
}
