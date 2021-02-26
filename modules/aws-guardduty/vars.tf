variable "aws_account_id" {
  type        = string
  description = "The AWS account id permitted to assume guardduty role."
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

variable "logging" {
  type        = map(any)
  description = "Enable logging in S3 bucket."
  default = {
    target_bucket = ""
    target_prefix = ""
  }
}

variable "detector_enable" {
  type        = bool
  description = "Enable monitoring and feedback reporting."
  default     = true
}

variable "has_ipset" {
  type        = bool
  description = "Whether to include IPSet."
  default     = false
}

variable "has_threatintelset" {
  type        = bool
  description = "Whether to include ThreatIntelSet."
  default     = false
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
  default     = ""
}

variable "threatintelset_activate" {
  type        = bool
  description = "Specifies whether GuardDuty is to start using the uploaded ThreatIntelSet."
  default     = true
}

variable "threatintelset_format" {
  type        = string
  description = "The format of the file that contains the ThreatIntelSet."
  default     = "TXT"
}

variable "threatintelset_iplist" {
  type        = string
  description = "ThreatIntelSet list of known malicious IP addresses."
  default     = ""
}
