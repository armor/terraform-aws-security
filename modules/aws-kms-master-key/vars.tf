variable "name" {
  description = "The name of the CMK. This is also used as the alias for the CMK."
  type        = string
}

variable "service_principals" {
  description = "A list of AWS service principals that should be given permissions to use this CMK."
  type = map(object({
    actions = list(string),
    conditions = list(object({
      test     = string,
      variable = string,
      values   = list(string)
    }))
  }))
  default = {}
}

variable "deletion_window_in_days" {
  description = "The number of days to retain this CMK after it has been marked for deletion."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "The value is expected to be in the range (7 - 30)."
  }
}

variable "enable_key_rotation" {
  description = "Whether or not to automatic annual rotation of the CMK is enabled."
  type        = bool
  default     = true
}

variable "customer_master_key_spec" {
  description = "Whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Any of `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
