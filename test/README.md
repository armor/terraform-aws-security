# Tests

This folder contains the tests for the modules in this repo.

## Running Locally

Many of these tests create real resources in the target accounts. That means they cost money to run, especially
if you don't clean up after yourself. Please be considerate of the resources you create and take extra care to clean
everything up when you're done!

**Never hit `CTRL + C` or cancel a build once tests are running, or the cleanup tasks won't run!**

We set `-timeout 45m` on all tests not because they necessarily take 45 minutes, but because Go has a default test
timeout of 10 minutes, after which it does a `SIGQUIT`, preventing the tests from properly cleaning up  after
themselves. Therefore, we set a timeout of 45 minutes to make sure all tests have enough time to finish and cleanup.

### Prerequisites

- [Install Go](https://golang.org/)
- [Install Terraform](https://github.com/quantum-sec/meta/tree/master/setup/terragrunt)
- [Login to the AWS CLI](https://github.com/quantum-sec/infrastructure-live-customer/blob/master/.tools/aws/aws-cli-login.sh)

### Run All of the Tests

```bash
go test -v -timeout 45m -parallel 128
```

#### Run a Specific Test

```bash
go test -v -timeout 45m -parallel 128 -run <test_name>
```
