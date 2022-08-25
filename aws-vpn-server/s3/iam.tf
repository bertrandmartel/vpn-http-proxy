locals {

  s3_buckets_policy_statement = <<CONFIG
{
    "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
    ],
    "Effect": "Allow",
    "Resource": "${aws_s3_bucket.playbook_bucket.arn}/*"
},
{
    "Action": [
        "s3:ListBucket",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts",
        "s3:ListBucketMultipartUploads"
    ],
    "Effect": "Allow",
    "Resource": "${aws_s3_bucket.playbook_bucket.arn}"
},
{
    "Sid": "S3CMK",
    "Effect": "Allow",
    "Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ],
    "Resource": ["${aws_kms_key.kms_s3.arn}"]
}
CONFIG
}

resource "random_id" "policy_name" {
  byte_length = 16
}

# Instance Policy S3
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.prefix}-vpn-http-proxy-vpn-policy-s3-${random_id.policy_name.hex}"
  path        = "/"
  description = "Provides AWS vpn-http-proxy instances access to s3 objects/bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ ${local.s3_buckets_policy_statement} ]
}
EOF
}
