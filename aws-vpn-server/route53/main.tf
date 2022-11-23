data "aws_route53_zone" "primary" {
  name = var.dns_zone
}

resource "aws_route53_record" "vpn_server_dns_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.vpn_server_dns
  type    = "A"
  ttl     = 300
  dynamic "geolocation_routing_policy" {
    for_each = var.route53_geolocation_policy == null ? [] : [var.route53_geolocation_policy]
    content {
      country = var.route53_geolocation_policy.country != null ? var.route53_geolocation_policy.country : null
    }
  }
  set_identifier = var.route53_geolocation_policy == null ? null : var.route53_identifier
  records = [var.public_ip]
}
