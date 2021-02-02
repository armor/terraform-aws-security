terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.22.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  auto_deploy_from_accounts = setunion(var.auto_deploy_from_accounts, [data.aws_caller_identity.current.account_id])
  developer_from_accounts   = setunion(var.developer_from_accounts, [data.aws_caller_identity.current.account_id])
}

module "roles" {
  source = "../../modules/aws-iam-roles"

  # this is our current account
  aws_account_id = data.aws_caller_identity.current.account_id

  # we allow the auto-deploy-from-external-accounts role to be assumed from these accounts
  auto_deploy_from_accounts = local.auto_deploy_from_accounts
  developer_from_accounts   = local.developer_from_accounts

  # we only allow codebuild to assume this role from the accounts listed in `auto_deploy_from_accounts`
  auto_deploy_service_principals = []

  # we only include the deny_all policy from the defaults
  include_default_policies = var.include_default_policies

  # we define budget_management_tooling_readonly policy in `my_custom_policies`
  policy_custom = var.my_custom_policies

  # we prefix all of our role names with `example-`
  role_name_static_prefix = var.role_name_static_prefix

  # we exclude budget_management_tooling_readonly policy from being deployed
  exclude_policies = setunion([
    # the aws_principals must be updated to not reference 123456789012.
    # The value of arn:aws:iam::123456789012:root be denied by AWS. with the error:
    # Assume Role Policy: MalformedPolicyDocument: Invalid principal in policy: "AWS":"arn:aws:iam::123456789012:root"
    # make sure to make that change before removing this custom policies from the `exclude_policies` list
    "budget_management_tooling_readonly",
    "budget_management_users_readonly",
  ], var.exclude_policies)

  developer_include_managed_policies = var.developer_include_managed_policies

  tags = {
    cost_center = "engineering"
  }
}

data "aws_caller_identity" "current" {
}
