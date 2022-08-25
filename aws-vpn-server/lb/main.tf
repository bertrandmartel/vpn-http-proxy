
resource "aws_lb" "vpn_server" {
  name               = "${var.prefix}-vpn-server-elb"
  load_balancer_type = "network"
  internal           = false
  subnets            = var.public_subnets
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-vpn-server-elb"
  })
}

resource "aws_lb_listener" "vpn_server" {
  load_balancer_arn = aws_lb.vpn_server.arn

  protocol = "TCP_UDP"
  port     = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpn_server.arn
  }
}

resource "aws_lb_target_group" "vpn_server" {
  port     = 443
  protocol = "TCP_UDP"
  vpc_id   = var.vpc_id
}
resource "aws_lb_target_group_attachment" "vpn_server" {
  target_group_arn = aws_lb_target_group.vpn_server.arn
  target_id        = var.instance_id
}
