name                     = "signing-cmk-test"
enable_key_rotation      = false
customer_master_key_spec = "ECC_NIST_P256"
key_usage                = "SIGN_VERIFY"
service_principal_policy_statements = {
  AllowRoute53DnssecService = {
    service = "dnssec-route53.amazonaws.com"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
    ]
    conditions = []
  }
  AllowRoute53DnssecToCreateGrant = {
    service = "dnssec-route53.amazonaws.com"
    actions = [
      "kms:CreateGrant",
    ]
    conditions = [{
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }]
  }
}
