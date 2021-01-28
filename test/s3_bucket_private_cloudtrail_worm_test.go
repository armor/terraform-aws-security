package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestPrivateCloudtrailS3BucketWORM(t *testing.T) {
	t.Parallel()

	modulePath := "../examples/aws-s3-private-cloudtrail-worm"

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	name := strings.ToLower(fmt.Sprintf("test-private-s3-bucket-%s", strings.ToLower(random.UniqueId())))

	// We are currently targeting only regions defined as ApprovedRegions in variables.go.
	// When we are comfortable with multi-region testing then we can expand ApprovedRegions
	// Eventually we may want to remove the array of ApprovedRegions and pass nil to only chose from stable regions.
	// This will help to ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, ApprovedRegions, nil)

	terraformOptions := &terraform.Options{
		TerraformDir: modulePath,
		Vars: map[string]interface{}{
			"name":                name,
			"aws_region":          awsRegion,
			"worm_mode":           "GOVERNANCE",
			"worm_retention_days": 1,
			"kms_master_key_arn":  "arn:aws:kms:ap-southeast-1:503776578075:key/a48b43a8-f7b2-4f01-97e6-8f668798e5fe",
			"enable_cloudtrail_bucket_access_logging": false,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	// Verify that our Bucket has versioning enabled
	actualStatus := aws.GetS3BucketVersioning(t, awsRegion, bucketID)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)
}
