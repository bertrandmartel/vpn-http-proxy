data "aws_vpc" "selected" {
  id = var.vpc_id
}
resource "aws_security_group" "vpn_server" {
  name_prefix = "${var.prefix}-vpn-server-"
  description = "Allow traffic to the AWS WAN VPN servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block] # this is only used for healthcheck
    self        = true
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = var.vpn_server_allowed_ips # openvpn server connection
    self        = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-vpn-server-sg"
  })
}
