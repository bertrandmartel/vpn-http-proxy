data "aws_subnet" "vpn" {
  id = var.public_subnet
}

resource "aws_eip" "vpn" {
  instance = aws_instance.vpn.id
  vpc      = true
}

resource "aws_instance" "vpn" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile.id
  subnet_id              = data.aws_subnet.vpn.id
  tags = merge(var.common_tags, {
    Name        = var.vpn_server_ec2_name
    vpn_client  = var.vpn_client ? "True" : "False"
    aws_wan_vpn = "True"
    vpn_http_proxy = "True"
  })
  user_data = <<EOF
#!/bin/bash
echo "${var.ca_cert_md5} ${var.public_cert_md5} ${var.private_cert_md5} ${var.playbook_sha} ${var.ssm_doc_sha}" > /dev/null
yum update
amazon-linux-extras install -y epel
yum install -y openvpn
EOF
  root_block_device {
    volume_type = var.root_block_volume_config.volume_type
    volume_size = var.root_block_volume_config.volume_size
    encrypted   = true
    kms_key_id  = aws_kms_key.kms_ebs.arn
  }
  volume_tags = var.common_tags
}

resource "aws_kms_key" "kms_ebs" {
  description              = "Key for ebs"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "false"
  tags = merge(var.common_tags, {
    Name = "kms_ebs"
  })
}