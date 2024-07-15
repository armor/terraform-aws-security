variable "name" {
  description = "The username assigned to the service account."
  type        = string
}

variable "path" {
  description = "The path in which to create the service account."
  type        = string
  default     = "/armor-service-accounts/"
}
