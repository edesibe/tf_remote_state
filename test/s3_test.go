package test

import (
	"fmt"
	"strings"
	"testing"

	awsSDK "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// An example of how to test the Terraform module in examples/terraform-aws-s3-example using Terratest.
func TestTerraformAwsS3Example(t *testing.T) {
	t.Parallel()

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	expectedName := fmt.Sprintf("terratest-s3-%s", strings.ToLower(random.UniqueId()))

	// Give this S3 Bucket an environment to operate as a part of for the purposes of resource tagging
	expectedEnvironment := "automatedtesting"

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := "us-west-1"

	// Expect that s3 bucket has versioning enabled
	expectedStatusVersioning := "Enabled"

	// Expected ownership
	expectedObjectOwnership := "BucketOwnerPreferred"

	// Expected SSE Algorithm
	expectedStatusEncriptionSSEAlgorithm := "aws:kms"

	// Expect that s3 bucket's public access block configuration is blocked
	expectedPublicAccessBlockConfiguration := &s3.PublicAccessBlockConfiguration{
		BlockPublicAcls:       awsSDK.Bool(true),
		BlockPublicPolicy:     awsSDK.Bool(true),
		IgnorePublicAcls:      awsSDK.Bool(true),
		RestrictPublicBuckets: awsSDK.Bool(true),
	}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/test1",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"environment": expectedEnvironment,
			"prefix":      expectedName,
			"region":      awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "s3_bucket_id")
	accountID := terraform.Output(t, terraformOptions, "aws_account_id")
	s3Policy := terraform.Output(t, terraformOptions, "s3_policy")

	// Verify that our Bucket has versioning enabled
	actualStatusVersioning := aws.GetS3BucketVersioning(t, awsRegion, bucketID)
	assert.Equal(t, expectedStatusVersioning, actualStatusVersioning)

	// Verify BucketOwnerPreffered ownership is set
	s3Client, err := aws.NewS3ClientE(t, awsRegion)
	require.NoError(t, err)

	actualStatusOwnership, err := s3Client.GetBucketOwnershipControls(&s3.GetBucketOwnershipControlsInput{Bucket: &bucketID})
	if assert.NoError(t, err) {
		assert.Equal(t, expectedObjectOwnership, awsSDK.StringValue(actualStatusOwnership.OwnershipControls.Rules[0].ObjectOwnership))
	}

	// Verify public_access_block is true
	acutalStatusPublicAccessBlock, err := s3Client.GetPublicAccessBlock(&s3.GetPublicAccessBlockInput{Bucket: &bucketID})
	if assert.NoError(t, err) {
		assert.Equal(t, expectedPublicAccessBlockConfiguration, acutalStatusPublicAccessBlock.PublicAccessBlockConfiguration)
	}

	// Verify server_side_encryption is aws:kms
	acutalStatusEncription, err := s3Client.GetBucketEncryption(&s3.GetBucketEncryptionInput{Bucket: &bucketID})
	if assert.NoError(t, err) {
		expectedStatusEncriptionKMSMasterKeyID := fmt.Sprintf("arn:aws:kms:%s:%s:alias/aws/s3", awsRegion, accountID)
		assert.Equal(t, expectedStatusEncriptionKMSMasterKeyID, awsSDK.StringValue(acutalStatusEncription.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.KMSMasterKeyID))
		assert.Equal(t, expectedStatusEncriptionSSEAlgorithm, awsSDK.StringValue(acutalStatusEncription.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm))
	}

	// Verify that our Bucket has a policy attached
	actualStatusPolicy, err := aws.GetS3BucketPolicyE(t, awsRegion, bucketID)
	if assert.NoError(t, err) {
		assert.JSONEq(t, s3Policy, actualStatusPolicy)
	}
}
