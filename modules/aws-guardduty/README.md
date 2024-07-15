# terraform-aws-guardduty

## Introduction

Amazon GuardDuty is a threat detection service that continuously monitors for malicious activity and unauthorized behavior to protect your AWS accounts, workloads, and data stored in Amazon S3.

## How it works?
Source: https://aws.amazon.com/guardduty/

![GuardDuty|medium](https://d1.awsstatic.com/product-marketing/Amazon%20GuardDuty/product-page-diagram-Amazon-GuardDuty_how-it-works.a4daf7e3aaf3532623a3797dd3af606a85fc2e7b.png)

## AWS GuardDuty Terraform

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.6 |

### Resources docs

These are the documentation for the resource that where implemented in our Terraform package:

| Name |Description|
|------|-----------|
| [aws_guardduty_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | A resource to enable GuardDuty monitoring. |
| [aws_guardduty_ipset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_ipset) | IPSet is use to define the list of trusted IP addresses. |
| [aws_guardduty_member](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_member) | This is use to accept member invitation. |
| [aws_guardduty_organization_admin_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | Manages a GuardDuty Organization Admin Account.  |
| [aws_guardduty_organization_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | Manages the GuardDuty Organization Configuration in the current AWS Region. |
| [aws_guardduty_threatintelset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_threatintelset) | ThreatIntelSet is use to define the list of known malicious IP addresses. |
| [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | Provides a S3 bucket object resource. |

### Caveats
Due to the way in which Terraform deals with the AWS API, it is not sufficient to alter the local contents of `iplist.txt` and
do another `terraform apply` - if the file is present in the target bucket, Terraform concludes it does not have any work to do,
so you will need to manually delete the file first.

The terraform code would not be creating the S3 bucket, you have to ensure that your guardduty admin account has access to the s3 bucket that would be use to store both the ip list and threat intel list.

### Inputs

The below outlines the current parameters and defaults.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_enable | When this setting is enabled, all new accounts that are created in, or added to, the organization are added as a member accounts of the organization’s GuardDuty delegated administrator and GuardDuty is enabled in that AWS Region. | `bool` | `false` | no |
| aws\_account\_id | The AWS account id permitted to assume guardduty role. | `string` | `null` | no |
| aws\_region | The primary region that the would be use for deployment. | `string` | n/a | yes |
| aws\_regions | List of regions where guardduty will be deployed. | `list(string)` | n/a | yes |
| bucket\_name | Name of the S3 bucket to use. | `string` | `""` | no |
| create\_detector | Create GuardDuty Detector for monitoring and feedback reporting. | `bool` | `false` | no |
| delegate_admin | Delegate the AWS Account specified in `aws_account_id` as the GuardDuty Admin. This can only be delegated from the Organization Management account. | `bool` | `false` | no |
| invite\_member\_accounts | Invite `member_list` as a GuardDuty member account to the current GuardDuty master account. | `bool` | `false` | no |
| ipset\_activate | Specifies whether GuardDuty is to start using the uploaded IPSet. | `bool` | `true` | no |
| ipset\_filename | Filename of the ipset list. | `string` | `"ipset.txt"` | no |
| ipset\_format | The format of the file that contains the IPSet. | `string` | `"TXT"` | no |
| ipset\_iplist | IPSet list of trusted IP addresses. | `string` | `null` | no |
| ipset\_name | Name of the ipset list. | `string` | `"IPSet"` | no |
| member\_list | The list of member accounts to be added to guardduty. | `map(string)` | `{}` | no |
| threat\_intel\_sets | Enable and configure threat intel sets. | <pre>list(object({<br>    name           = string,<br>    filename       = string,<br>    format         = string,<br>    content        = string,<br>    ignore_content = bool,<br>    activate       = bool,<br>  }))</pre> | `[]` | no |

### Examples

#### Basic Setting

GuardDuty admin is delegated from the Organization Management account and a GuardDuty detector is configured in the delegated admin account:

```tf
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY GUARDDUTY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 1.2" = ">= 0.14.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AND ENABLE GUARDDUTY
# ---------------------------------------------------------------------------------------------------------------------

module "guardduty" {
  source = "git::git@github.com:armor/terraform-aws-security.git//modules/aws-guardduty?ref=2.0.1"

  aws_account_id = "xxxxxxxxxxxx"
  main_region   = "ap-southeast-1"
  aws_region     = ["ap-southeast-1"]
  delegate_admin         = true
  invite_member_accounts = false
  create_detector        = false
}
```

To apply that:

```text
▶ terraform apply
```

#### Auto add user

A GuardDuty instance configured as a Master that invites a list of members: (detector is already created through admin delegation)

```tf
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY GUARDDUTY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 1.2" = ">= 0.14.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AND ENABLE GUARDDUTY
# ---------------------------------------------------------------------------------------------------------------------

module "guardduty" {
  source = "git::git@github.com:armor/terraform-aws-security.git//modules/aws-guardduty?ref=2.0.1"

  aws_account_id = "xxxxxxxxxxxx"
  aws_region     = "ap-southeast-1"
  aws_regions    = ["ap-southeast-1"]
  member_list    = {xxxxxxxxxxxx = "xxx@xxx.com", yyyyyyyyyyyy = "yyy@yyy.com"}

  delegate_admin         = false
  invite_member_accounts = true
  create_detector        = false
}
```

To apply that:

```text
▶ terraform apply
```

#### With ipset and threatintelset enabled

A GuardDuty instance configured as a Master that invites a list of members: (detector is already created through admin delegation)

```hcl
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY GUARDDUTY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 1.2" = ">= 0.14.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AND ENABLE GUARDDUTY
# ---------------------------------------------------------------------------------------------------------------------

module "guardduty" {
  source = "git::git@github.com:armor/terraform-aws-security.git//modules/aws-guardduty?ref=2.0.1"

  aws_account_id         = "xxxxxxxxxxxx"
  aws_region             = "ap-southeast-1"
  aws_regions            = ["ap-southeast-1"]
  member_list            = {xxxxxxxxxxxx = "xxx@xxx.com", yyyyyyyyyyyy = "yyy@yyy.com"}
  delegate_admin         = false
  invite_member_accounts = true
  create_detector        = false

  bucket_name           = "s3-audit-guardduty"

  ipset_iplist          = "1.1.1.1"

  threat_intel_sets = [
    {
      name = "ThreatIntelSet",
      filename = "threatintelset.txt",
      format = "TXT",
      content = null,
      ignore_content = true,
      activate = true,
    },
  ]
}
```

To apply that:

```text
▶ terraform apply
```
