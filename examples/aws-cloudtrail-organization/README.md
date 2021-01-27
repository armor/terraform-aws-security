# Example Organization Cloudtrail

This is an example of how to use the [aws-cloudtrail module](/modules/aws-cloudtrail) to create a
[Amazon S3](https://aws.amazon.com/s3/) WORM bucket, [KMS](https://aws.amazon.com/kms/)
[CMK](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#master_keys) for
encrypting/decrypting, and a
[trail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html#cloudtrail-concepts-trails)
for [cloudtrail](https://aws.amazon.com/cloudtrail/) logs.

1. Apply the [example aws-audit-cloudtrail-bucket](/examples/aws-cloudtrail-organization/aws-audit-cloudtrail-bucket)
1. Apply the [example aws-org-cloudtrail](/examples/aws-cloudtrail-organization/aws-org-cloudtrail)

> **NOTE:** When applying `aws-audit-cloudtrail-bucket` you will need to provide the `name` and a list of aws account ids
> that will be writing trail logs to the bucket.
>
> running in our logging account with the aws account id: `123456789012`
>
> example: `terraform apply -var name=quantum-123 -var aws_account_ids='["123456789012", "234567890123", "345678901234"]'`

> **NOTE:** When applying `aws-org-cloudtrail` you will need to use values from the output of `aws-audit-cloudtrail-bucket`
> values: `s3_bucket_name`, `kms_key_arn`
> `name` is used to name the trail while `s3_bucket_name` is passed to the trail to log events to the specified bucket.
> these values can be static, well known, names.  The S3 bucket name must be globally unique so this example includes your
> aws_account_id in the name.
>
> running in our organization management account with the aws account id: `234567890123`, pointing to s3 and kms in `123456789012`
>
> example: `terraform plan -var name=quantum-123 -var s3_bucket_name=cloudtrail-123456789012-example-quantum-123 -var kms_key_arn="arn:aws:kms:ap-southeast-1:123456789012:key/4b2f0c70-b503-4849-8286-34a6938c88a7"`

In this example we are splitting the cloudtrail away from the S3 and CMK.  This helps to ensure that we do not have production
workloads in our organization account.  In addition to no production workloads in this account we can also provide very limited
access to the audit/logging account.

Further reading on the permissions for setting up the CMK policy for cloudtrail can be found
[here](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-kms-key-policy-for-cloudtrail.html)

Further reading on WORM buckets can be found on the
[AWS Blog](https://aws.amazon.com/blogs/storage/protecting-data-with-amazon-s3-object-lock/)

> Amazon S3 Object Lock is an Amazon S3 feature that allows you to store objects using a write once, read many (WORM) model.
> You can use WORM protection for scenarios where it is imperative that data is not changed or deleted after it has been written.
> Whether your business has a requirement to satisfy compliance regulations in the financial or healthcare sector, or you simply
> want to capture a golden copy of business records for later auditing and reconciliation, S3 Object Lock is the right tool for you.
>
> S3 Object Lock has been assessed for SEC Rule 17a-4(f), FINRA Rule 4511, and CFTC Regulation 1.31 by Cohasset Associates.
