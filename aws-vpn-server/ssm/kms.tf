resource "aws_kms_key" "kms_ssm" {
  description              = "Key for ssm"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "false"
  tags = merge(var.common_tags, {
    Name = "kms_ssm"
  })
}
