# Example Private Write Once Read Many S3 bucket for Cloudtrail

This is an example of how to use the [aws-s3-private-cloudtrail module](/modules/aws-s3-private-cloudtrail) to create an
[Amazon S3](https://aws.amazon.com/s3/) bucket for use with cloudtrail and a CMK for encrypting the cloudtrail logs.
This example assumes that you do not have a CMK setup with an approprate policy permitting cloudtrail to use the key for encryption.
Without the correct policy your cloudtrail logs will not be written into the s3 bucket.

If you need to find an example that uses an existing CMK for cloudtrail to encrypt objects then see the
[aws-s3-private-cloudtrail-worm example](/examples/aws-s3-private-cloudtrail-worm).

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
