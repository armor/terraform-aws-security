package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Setup(path string) {
	providerPath := path + "/provider.tf"
	defer os.Remove(providerPath)
	files.CopyFile("../test-provider.tf", providerPath)
}

func TearDown(path string) {
	defer os.Remove(path + "/provider.tf")
}

func TestSimpleCmkCreation(t *testing.T) {
	t.Parallel()

	modulePath := "../examples/aws-kms-master-key"
	name := "example"
	expectedAlias := "alias/example"

	Setup(modulePath)

	terraformOptions := &terraform.Options{
		TerraformDir: modulePath,
		Vars: map[string]interface{}{
			"name": name,
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	actualAlias := terraform.Output(t, terraformOptions, "key_alias")

	assert.Equal(t, expectedAlias, actualAlias)

	TearDown(modulePath)
}
