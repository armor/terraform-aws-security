# Private S3 Bucket

This module creates an [Amazon S3](https://aws.amazon.com/s3/) bucket that enforces
best practices for private access:

- Public access is explicitly blocked and ignored.
- server-side encryption is enabled by default via `aws:kms` and may be configured
to use AES256 with a CMK
- The S3 bucket explicitly denies requests that are not using TLS.
- Access logging is enabled by default with the same encryption settings.

## How can you use this module?

* See the [example aws-s3-bucket-private](/examples/aws-s3-bucket-private) for a
working example.
* See [`vars.tf`](vars.tf) for configurations.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.private_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.private_s3_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.private_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs_private_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.private_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.private_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.existing_private_s3_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_s3_integration_services"></a> [allow\_s3\_integration\_services](#input\_allow\_s3\_integration\_services) | Add a secure s3 bucket policy allowing s3 services to PutItem into the bucket. Used by Analytics and Inventory. | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | What to name the S3 bucket. Note that S3 bucket names must be globally unique across all AWS users! | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_kms_master_key_arn"></a> [kms\_master\_key\_arn](#input\_kms\_master\_key\_arn) | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default `aws/s3` AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`. | `string` | `null` | no |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the target bucket that will receive the log objects. This defaults to `name`-logs. If `logging_bucket_name` is specified then the named s3 bucket is not created by this module. | `string` | `null` | no |
| <a name="input_logging_bucket_prefix"></a> [logging\_bucket\_prefix](#input\_logging\_bucket\_prefix) | To specify a key prefix for log objects. This prefix is used to prefix server access log objects when `logging_enabled` is `true` and generally should only be used when multiple s3 buckets are logging to a single s3 bucket which can be defined with `logging_bucket_name`. Key prefixes are useful to distinguish between source buckets when multiple buckets log to the same target bucket. | `string` | `""` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Toggle access logging of this S3 bucket. | `bool` | `true` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Enable Write Once Read Many (WORM). Object-lock Configuration of S3 Bucket can use GOVERNANCE or COMPLIANCE mode. COMPLIANCE can not be removed while GOVERNANCE can be disabled by the root user. `versioning_enabled` must be set to true for this to be enabled. This configuration can only be set on a new S3 bucket, otherwise you will need to contact AWS Support to have it configured. | <pre>object({<br>    # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html#object-lock-retention-modes<br>    # If the mode is set to GOVERNANCE then either the s3:BypassGovernanceRetention or s3:GetBucketObjectLockConfiguration<br>    # permissions will allow the deletion of locked objects<br>    mode = string<br>    # minimum 1 days<br>    days = number<br>  })</pre> | `null` | no |
| <a name="input_policy_json"></a> [policy\_json](#input\_policy\_json) | Additional base S3 bucket policy in JSON format. | `list(string)` | `[]` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | `string` | `"aws:kms"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A key-value map of tags to apply to this resource. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enables ability to keep multiple variants of an object in the bucket. Versioning can not be disabled once enabled. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the private S3 Bucket. |
| <a name="output_block_public_acls"></a> [block\_public\_acls](#output\_block\_public\_acls) | Whether Amazon S3 blocks new public ACLs for this bucket. |
| <a name="output_block_public_policy"></a> [block\_public\_policy](#output\_block\_public\_policy) | Whether Amazon S3 blocks new public bucket policies for this bucket. |
| <a name="output_bucket_logging_arn"></a> [bucket\_logging\_arn](#output\_bucket\_logging\_arn) | The target ARN of the private S3 Bucket where access logs are stored. |
| <a name="output_bucket_logging_enabled"></a> [bucket\_logging\_enabled](#output\_bucket\_logging\_enabled) | Whether or not access logging is enabled for this bucket. |
| <a name="output_id"></a> [id](#output\_id) | The name of the private S3 Bucket. |
| <a name="output_ignore_public_acls"></a> [ignore\_public\_acls](#output\_ignore\_public\_acls) | Whether Amazon S3 ignores existing public ACLs for this bucket. |
| <a name="output_restrict_public_buckets"></a> [restrict\_public\_buckets](#output\_restrict\_public\_buckets) | Whether or not public bucket policies are restricted for this bucket. |
<!-- END_TF_DOCS -->
