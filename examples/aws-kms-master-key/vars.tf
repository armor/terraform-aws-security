variable "name" {
  description = "The name of the CMK. This is also used as the alias for the CMK."
  type        = string
}

variable "service_principal_policy_statements" {
  description = "A map of policy statements that will be applied to the CMK key policy. The key should be the statement's SID and the value should be the statement configuration object."
  type = map(object({
    service = string,
    actions = list(string),
    conditions = list(object({
      test     = string,
      variable = string,
      values   = list(string)
    }))
  }))
}

variable "deletion_window_in_days" {
  description = "The number of days to retain this CMK after it has been marked for deletion."
  type        = number
  default     = 30
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

variable "key_usage" {
  description = "Specifies the intended use of the key."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "tags" {
  description = "A key-value map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}
