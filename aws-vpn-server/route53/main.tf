data "aws_route53_zone" "primary" {
  name = var.dns_zone
}

resource "aws_route53_record" "vpn_server_dns_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.vpn_server_dns
  type    = "A"

  dynamic "geolocation_routing_policy" {
    for_each = var.route53_geolocation_policy == null ? [] : [var.route53_geolocation_policy]
    content {
      country = var.route53_geolocation_policy.country != null ? var.route53_geolocation_policy.country : null
    }
  }
  set_identifier = var.route53_geolocation_policy == null ? null : var.route53_identifier
  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = false
  }
}
