data "aws_caller_identity" "current" {}

# s3 playbook bucket
resource "aws_s3_bucket" "playbook_bucket" {
  bucket = "${var.prefix}-vpn-playbook"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy = true
  tags = merge(var.common_tags, {
    Name = "kms_s3"
  })
  policy = templatefile(
    "${path.module}/s3_policy.json",
    {
      "account_id" = data.aws_caller_identity.current.account_id
      "bucket"     = "${var.prefix}-vpn-playbook"
    }
  )
}

# s3 objects (playbook)
resource "aws_s3_bucket_object" "playbook_files" {
  for_each       = fileset("${path.module}/../playbook/", "**")
  bucket         = aws_s3_bucket.playbook_bucket.id
  key            = "playbook/${each.value}"
  content_base64 = base64encode(file("${path.module}/../playbook/${each.value}"))
  kms_key_id     = aws_kms_key.kms_s3.arn
}
