variable "dns_zone" {
  description = "DNS zone name (example.com)"
}
variable "vpn_server_dns" {
  description = "VPN server domain name (vpn.example.com)"
}
variable "route53_geolocation_policy" {
  description = "sepcify geolocation policy"
  type = object({
    country = string
  })
  default = null
}
variable "route53_identifier" {
  description = "Route53 record identifier"
  default     = "secure"
  type        = string
}
variable "public_ip" {
  type = string
}