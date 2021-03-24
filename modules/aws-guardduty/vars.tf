variable "aws_account_id" {
  type        = string
  description = "The AWS account id that will be delegated administrator of GuardDuty when `delegate_admin` is set to `true` and this module is applied in the organization management account."
}

variable "aws_region" {
  type        = string
  description = "The primary region that the would be use for deployment."
}

variable "aws_regions" {
  type        = list(string)
  description = "List of regions where guardduty will be deployed."
}

variable "member_list" {
  type        = map(string)
  description = "The list of member accounts to be added to guardduty.  The map should have key names of the aws account id and a string value of the root users email address of that member account.  i.e. `{ \"123456789012\" = \"rootuser@example.com\" }`."
  default     = {}
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to use."
  default     = ""
}

variable "delegate_admin" {
  type        = bool
  description = "Delegate the AWS Account specified in `aws_account_id` as the GuardDuty Admin. This can only be delegated from the Organization Management account."
  default     = false
}

variable "invite_member_accounts" {
  type        = bool
  description = "Invite `member_list` as a GuardDuty member account to the current GuardDuty master account."
  default     = false
}

variable "create_detector" {
  type        = bool
  description = "Create GuardDuty Detector for monitoring and feedback reporting."
  default     = false
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
    error_message = "Threat intel sets must contain 6 or less items."
  }
}
