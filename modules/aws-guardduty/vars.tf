variable "aws_account_id" {
  type        = string
  description = "The AWS account id permitted to assume guardduty role."
}

variable "main_region" {
  type        = string
  description = "The primary region that the would be use for deployment."
}

variable "aws_regions" {
  type        = list(any)
  description = "List of regions where guardduty will be deployed."
}

variable "group_name" {
  type        = string
  description = "The guardduty group's name."
  default     = "guardduty-admin"
}

variable "member_list" {
  type        = map(string)
  description = "The list of member accounts to be added to guardduty."
  default     = {}
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to use."
  default     = ""
}

variable "detector_enable" {
  type        = bool
  description = "Enable monitoring and feedback reporting."
  default     = true
}

variable "ipset_name" {
  type        = string
  description = "Name of the ipset list."
  default     = "IPSet"
}

variable "ipset_filename" {
  type        = string
  description = "Filename of the ipset list."
  default     = "ipset.txt"
}

variable "ipset_activate" {
  type        = bool
  description = "Specifies whether GuardDuty is to start using the uploaded IPSet."
  default     = true
}

variable "ipset_format" {
  type        = string
  description = "The format of the file that contains the IPSet."
  default     = "TXT"
}

variable "ipset_iplist" {
  type        = string
  description = "IPSet list of trusted IP addresses."
  default     = null
}

variable "threat_intel_sets" {
  type = list(object({
    name           = string,
    filename       = string,
    format         = string,
    content        = string,
    ignore_content = bool,
    activate       = bool,
  }))
  description = "Enable and configure threat intel sets."
  default     = []

  validation {
    condition     = length(var.threat_intel_sets) <= 6
    error_message = "Threat intel sets should only contain 6 or less set of list."
  }
}
