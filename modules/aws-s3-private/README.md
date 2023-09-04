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
