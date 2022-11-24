resource "aws_iam_role" "vpn_server_role" {
  name                 = "${var.prefix}-vpn-http-proxy-server-role"
  permissions_boundary = var.permissions_boundary
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

# Instance tags policy
resource "aws_iam_policy" "instance_tags" {
  name        = "${var.prefix}-vpn-policy-tags"
  path        = "/"
  description = "get the instance tags"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
}
data "aws_iam_policy" "instance_policy_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# server role attachment
resource "aws_iam_role_policy_attachment" "instance_tags_server" {
  role       = aws_iam_role.vpn_server_role.name
  policy_arn = aws_iam_policy.instance_tags.arn
}
resource "aws_iam_role_policy_attachment" "ssm_server" {
  role       = aws_iam_role.vpn_server_role.name
  policy_arn = var.vpn_policy_server.arn
}
resource "aws_iam_role_policy_attachment" "s3_server" {
  role       = aws_iam_role.vpn_server_role.name
  policy_arn = var.s3_policy.arn
}
resource "aws_iam_role_policy_attachment" "ssm_instance_server" {
  role       = aws_iam_role.vpn_server_role.name
  policy_arn = data.aws_iam_policy.instance_policy_ssm.arn
}

# server instance profile
resource "aws_iam_instance_profile" "server_profile" {
  name = "vpn_server_http_proxy_profile"
  role = aws_iam_role.vpn_server_role.name
}
