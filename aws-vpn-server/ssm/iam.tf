resource "random_id" "policy_name" {
  byte_length = 16
}

# Instance Policy Secret server 
resource "aws_iam_policy" "instance_policy_secret_server" {
  name        = "${var.prefix}-aws-wan-vpn-secret-ssm-${random_id.policy_name.hex}"
  path        = "/"
  description = "Provides vpn server access to secret"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SSHKeys",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "${var.vpn_server_secret.arn}"
      ]
    }
  ]
}
EOF
}
