# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_account_id" {
  description = "The ID of the AWS Account."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "role_name_static_prefix" {
  description = "A static string that will be prefixed to the name of the role. This is not the same as `name_prefix` in that it does not generate a unique name, but instead provides a static string prefix to the role name."
  type        = string
  default     = ""
}

variable "allow_assume_role" {
  description = "Allow the Roles to be assumed when using IAM."
  type        = string
  default     = true
}
variable "allow_assume_role_with_saml" {
  description = "Allow the Roles to be assumed when using IAM."
  type        = string
  default     = true
}
variable "allow_assume_role_with_web_identity" {
  description = "Allow the Roles to be assumed when using IAM."
  type        = string
  default     = true
}

variable "default_path" {
  description = "The path to the role. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/Using_Identifiers.html) for more information."
  type        = string
  default     = "/"
}

variable "include_default_policies" {
  description = "An explicit list of default polices to include. If a default policy is not listed in this array then it will not be deployed."
  type        = set(string)
  default = [
    # "auto_deploy_from_external_accounts",
    # "deny_all",
    # "developer_from_external_accounts",
    # "self_manage",
  ]
}

variable "exclude_policies" {
  description = "An explicit list of policies to exclude. If a policy name is in this list then it will never be deployed. This setting will override `include_default_policies`."
  type        = set(string)
  default = [
    "auto_deploy_from_external_accounts",
    "deny_all",
    "developer_from_external_accounts",
    "self_manage",
  ]
}

variable "auto_deploy_policy" {
  description = "A policy that will completely overwrite the default auto-deploy-from-external-accounts policy."

  type = object({
    name                 = string
    description          = string
    path                 = string
    policy               = string
    service_principals   = list(string)
    aws_principals       = list(string)
    federated_principals = list(string)
    iam_policy_arns      = list(string)
    role_requires_mfa    = bool
  })

  default = null
}

variable "auto_deploy_actions" {
  description = "A list of AWS IAM Actions that will be assigned to the auto-deploy-from-external-accounts policy. For limiting to specific resources you will need to fully define `auto_deploy_policy` with your custom policy."
  type        = list(string)
  default = [
    "apigateway:*",
    "autoscaling:*",
    "cloudfront:*",
    "cloudwatch:*",
    "codebuild:*",
    "codedeploy:*",
    "codestar-notifications:*",
    "dynamodb:*",
    "ec2:*",
    "ecr:*",
    "ecs:*",
    "eks:*",
    "elasticloadbalancing:*",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:GetRole",
    "iam:GetRolePolicy",
    "iam:ListEntitiesForPolicy",
    "iam:PassRole",
    "lambda:*",
    "logs:*",
    "route53:*",
    "s3:*",
    "sns:*",
    "sqs:*",
    "ssm:*",
  ]
}

variable "auto_deploy_from_accounts" {
  description = "A list of AWS principals (ARNs) permitted to assume the auto-deploy-from-external-accounts role."
  type        = set(string)
  default     = []
}

variable "auto_deploy_service_principals" {
  description = "A list service principals permitted to assume the auto-deploy-from-external-accounts role."
  type        = set(string)
  default     = []
}

variable "developer_policy" {
  description = "A policy that will completely overwrite the default developer policy."
  type = object({
    name                 = string
    description          = string
    path                 = string
    policy               = string
    service_principals   = list(string)
    aws_principals       = list(string)
    federated_principals = list(string)
    iam_policy_arns      = list(string)
    role_requires_mfa    = bool
  })
  default = null
}

variable "developer_actions" {
  description = "A list of AWS IAM Actions that will be assigned to the developer-from-external-accounts policy. For limiting to specific resources you will need to fully define `developer_policy` with your custom policy."
  type        = list(string)
  default = [
    "chatbot:DescribeSlackChannelConfigurations",
    "cloudwatch:GetMetricStatistics",
    "codebuild:BatchGet*",
    "codebuild:DescribeCodeCoverages",
    "codebuild:DescribeTestCases",
    "codebuild:GetResourcePolicy",
    "codebuild:List*",
    "codebuild:RetryBuild",
    "codebuild:RetryBuildBatch",
    "codebuild:StartBuild",
    "codebuild:StartBuildBatch",
    "codebuild:StopBuild",
    "codebuild:StopBuildBatch",
    "codecommit:GetBranch",
    "codecommit:GetCommit",
    "codecommit:GetRepository",
    "codecommit:ListBranches",
    "codedeploy:Batch*",
    "codedeploy:CreateDeployment",
    "codedeploy:Get*",
    "codedeploy:List*",
    "codedeploy:RegisterApplicationRevision",
    "codepipeline:GetPipeline",
    "codepipeline:GetPipelineExecution",
    "codepipeline:GetPipelineState",
    "codepipeline:ListActionExecutions",
    "codepipeline:ListActionTypes",
    "codepipeline:ListPipelineExecutions",
    "codepipeline:ListPipelines",
    "codepipeline:ListTagsForResource",
    "codestar-notifications:CreateNotificationRule",
    "codestar-notifications:DescribeNotificationRule",
    "codestar-notifications:ListEventTypes",
    "codestar-notifications:ListNotificationRules",
    "codestar-notifications:ListTagsforResource",
    "codestar-notifications:ListTargets",
    "codestar-notifications:Subscribe",
    "codestar-notifications:Unsubscribe",
    "codestar-notifications:UpdateNotificationRule",
    "events:DescribeRule",
    "events:ListRuleNamesByTarget",
    "events:ListTargetsByRule",
    "logs:GetLogEvents",
    "s3:GetBucketLocation",
    "s3:GetBucketPolicy",
    "s3:GetObject",
    "s3:ListAllMyBuckets",
    "s3:ListBucket",
    "sns:ListTopics",
    "ssm:PutParameter",
    "ssm:StartSession",
  ]
}

variable "developer_include_managed_policies" {
  description = "A list of AWS Managed Policies to copy and attach to the developer-from-external-accounts role"
  type        = set(string)
  default     = []
}

variable "self_manage_policy" {
  description = "A policy that will completely overwrite the default self_manage policy."
  type = object({
    name                 = string
    description          = string
    path                 = string
    policy               = string
    service_principals   = list(string)
    aws_principals       = list(string)
    federated_principals = list(string)
    iam_policy_arns      = list(string)
    role_requires_mfa    = bool
  })
  default = null
}

variable "developer_from_accounts" {
  description = "A list of AWS principals (ARNs) permitted to assume the developer-from-external-accounts role."
  type        = set(string)
  default     = []
}

variable "policy_custom" {
  description = "Any custom policies that should be deployed. These custom policies will be shallow merged on top of the defaults, allowing you to fully overwrite what the default policy is. Minimal defaults will be applied if not defined in the custom policy."
  type        = map(any)
  default = {
    # budget_management_tooling_readonly = {
    #   name              = "budget_management_tooling_readonly"
    #   description       = "The policy providing read-only access for Budget Management tooling"
    #   policy            = "{ \"statement\": [{ \"Effect\": \"Allow\", \"Action\": [\"aws-portal:ViewBilling\", \"budgets:ViewBudget\", \"budgets:Describe*\"], \"Resource\": \"*\" }] }"
    #   aws_principals    = ["arn:aws:iam::123456789012:root"]
    #   role_requires_mfa = false
    # }
    # budget_management_users_readonly = {
    #   name              = "budget_management_users_readonly"
    #   description       = "The policy providing read-only access for Budget Management users"
    #   policy            = "{ \"statement\": [{ \"Effect\": \"Allow\", \"Action\": [\"aws-portal:ViewBilling\", \"budgets:ViewBudget\", \"budgets:Describe*\"], \"Resource\": \"*\" }] }"
    #   aws_principals    = ["arn:aws:iam::123456789012:root"]
    #   role_requires_mfa = true
    # }
  }
}
