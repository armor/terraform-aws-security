# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region into which this resource is deployed."
  type        = string
  default     = "ap-southeast-1"
}


variable "auto_deploy_from_accounts" {
  description = "A list of AWS principals (ARNs) permitted to assume the auto-deploy-from-external-accounts role. If not set then the role will not be created."
  type        = set(string)
  default     = []
}

variable "developer_from_accounts" {
  description = "A list of AWS principals (ARNs) permitted to assume the developer-from-external-accounts role. If not set then the role will not be created."
  type        = set(string)
  default     = []
}

variable "support_from_accounts" {
  description = "A list of AWS principals (ARNs) permitted to assume the support-from-external-accounts role. If not set then the role will not be created."
  type        = set(string)
  default     = []
}

variable "developer_include_managed_policies" {
  type = list(string)
  default = [
    "AWSCodeBuildDeveloperAccess",
    "AWSCodeDeployDeployerAccess",
    "AmazonS3ReadOnlyAccess",
  ]
}

variable "my_custom_policies" {
  type        = map(any)
  description = "An example map of policies that may be defined by you and deployed."
  default = {
    budget_management_tooling_readonly = {
      name              = "budget_management_tooling_readonly"
      description       = "The policy providing read-only access for Budget Management tooling."
      policy            = "{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Effect\": \"Allow\", \"Action\": [\"aws-portal:ViewBilling\", \"budgets:ViewBudget\", \"budgets:Describe*\"], \"Resource\": \"*\" }] }"
      aws_principals    = ["arn:aws:iam::123456789012:root"]
      role_requires_mfa = false
    }

    budget_management_users_readonly = {
      name              = "budget_management_users_readonly"
      description       = "The policy providing read-only access for Budget Management users."
      policy            = "{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Effect\": \"Allow\", \"Action\": [\"aws-portal:ViewBilling\", \"budgets:ViewBudget\", \"budgets:Describe*\"], \"Resource\": \"*\" }] }"
      aws_principals    = ["arn:aws:iam::123456789012:root"]
      role_requires_mfa = true
    }
  }
}

variable "policy_name_static_prefix" {
  description = "A static string that will be prefixed to the name of the policy."
  type        = string
  default     = "example_"
}

variable "role_name_static_prefix" {
  description = "A static string that will be prefixed to the name of the role. This is not the same as `name_prefix` in that it does not generate a unique name, but instead provides a static string prefix to the role name."
  type        = string
  default     = "example-"
}

variable "included_default_policy_names" {
  description = "An explicit list of default polices to include. If a default policy is not listed in this array then it will not be deployed."
  type        = set(string)
  default = [
    "auto_deploy_from_external_accounts",
    "developer_from_external_accounts",
    "support_from_external_accounts",
  ]
}

variable "excluded_policy_names" {
  description = "An explicit list of policies to exclude. If a policy name is in this list then it will never be deployed. This setting will override `included_default_policy_names`."
  type        = set(string)
  default = [
    "deny_all",
  ]
}
