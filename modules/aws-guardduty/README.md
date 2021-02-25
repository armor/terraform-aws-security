# terraform-aws-guardduty

## Introduction

Amazon GuardDuty is a threat detection service that continuously monitors for malicious activity and unauthorized behavior to protect your AWS accounts, workloads, and data stored in Amazon S3.

## How it works?
Source: https://aws.amazon.com/guardduty/

![GuardDuty|medium](https://d1.awsstatic.com/product-marketing/Amazon%20GuardDuty/product-page-diagram-Amazon-GuardDuty_how-it-works.a4daf7e3aaf3532623a3797dd3af606a85fc2e7b.png)

## AWS GuardDuty Terraform

### Resources docs

These are the documentation for the resource that where implemented in our Terraform package:

- [`aws_guardduty_detector`](https://www.terraform.io/docs/providers/aws/r/guardduty_detector.html) - A resource to enable GuardDuty monitoring.
- [`aws_guardduty_ipset`](https://www.terraform.io/docs/providers/aws/r/guardduty_ipset.html) - IPSet is a list of trusted IP addresses.
- [`aws_guardduty_threatintelset`](https://www.terraform.io/docs/providers/aws/r/guardduty_threatintelset.html) - ThreatIntelSet is a list of known malicious IP addresses.

### Caveats
Due to the way in which Terraform deals with the AWS API, it is not sufficient to alter the local contents of `iplist.txt` and
do another `terraform apply` - if the file is present in the target bucket, Terraform concludes it does not have any work to do,
so you will need to manually delete the file first.

### Inputs

The below outlines the current parameters and defaults.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
|aws_account_id|The AWS account id permitted to assume guardduty role.|string|""|Yes|
|aws_regions|List of regions where guardduty will be deployed.|list|""|Yes|
|member_list|The list of member accounts to be added to guardduty.|map(string)|""|Yes|
|group_name|The guardduty group's name.|string|guardduty-admin|No|
|bucket_name|Name of the S3 bucket to use|string|""|Yes (If ipset or threat intel set is enabled)|
|logging|Enable logging in S3 bucket.|map|default = {target_bucket = "", target_prefix = ""|No|
|detector_enable|Enable monitoring|bool|true|Yes|
|has_ipset|Enable IPSet|bool|false|No|
|has_threatintelset|Enable ThreatIntelSet|bool|false|No|
|ipset_activate|Specifies whether GuardDuty is to start using the uploaded IPSet|bool|true|No|
|ipset_format|The format of the file that contains the IPSet|string|TXT|No|
|ipset_iplist|IPSet list of trusted IP addresses|list|[]|No|
|threatintelset_activate|Specifies whether GuardDuty is to start using the uploaded ThreatIntelSet|bool|true|No|
|threatintelset_format|The format of the file that contains the ThreatIntelSet|string|TXT|No|
|threatintelset_iplist|ThreatIntelSet list of known malicious IP addresses|list|[]|No|

### Outputs

|Name|Description|
|------------|---------------------|
|guardduty_account_id|The AWS account ID of the GuardDuty detector|
|guardduty_arn|Amazon Resource Name (ARN) of the GuardDuty detector.|
|guardduty_id|The ID of the GuardDuty detector|

### Examples

#### Basic Setting

A GuardDuty instance configured as a Master that invites a list of members:

```tf
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY GUARDDUTY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 0.14.6"

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
  source = "git::git@github.com:quantum-sec/package-aws-security.git//modules/aws-guardduty?ref=2.0.1"

  aws_account_id = "xxxxxxxxxxxx"
  aws_region     = ["ap-southeast-1"]
}
```

To apply that:

```text
▶ terraform apply
```

#### With ipset and threatintelset enabled

A GuardDuty instance configured as a Master that invites a list of members:

```tf
terraform {
  required_version = ">= 0.14.6"

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
  source = "git::git@github.com:quantum-sec/package-aws-security.git//modules/aws-guardduty?ref=2.0.1"

  aws_account_id        = "xxxxxxxxxxxx"
  aws_region            = ["ap-southeast-1"]

  bucket_name           = "s3-audit-guardduty"

  has_ipset             = true
  ipset_iplist          = "1.1.1.1"

  has_threatintelset    = true
  threatintelset_iplist = "2.2.2.2"
}
```

To apply that:

```text
▶ terraform apply
```
