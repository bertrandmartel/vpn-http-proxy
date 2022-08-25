resource "aws_kms_key" "kms_s3" {
  description              = "Key for s3 bucket"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "false"
  tags = merge(var.common_tags, {
    Name = "kms_s3"
  })
}
