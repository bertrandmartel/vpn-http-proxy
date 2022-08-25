variable "vpc_id" {
  type = string
}
variable "common_tags" {
  default     = {}
  description = "common tags"
  type        = map(string)
}
variable "prefix" {
  description = "objects prefix"
  default     = "prod"
}
variable "permissions_boundary" {
  description = "permission boundary arn to create IAM role"
  default     = null
}
variable "ec2_vpn_ami" {
  description = "VPN server AMI Amazon Linux 2"
}
variable "ec2_vpn_instance_type" {
  description = "VPN server EC2 instance type"
  default     = "t2.medium"
}
variable "private_subnet" {
  type        = string
  description = "The private subnet to deploy vpn server & vpn client to"
}
variable "public_subnets" {
  type        = list(any)
  description = "The public subnets to deploy the classic load balancer to"
}
variable "root_block_volume_config" {
  description = "config of the root volume of Gitlab EC2 instance"
  type = object({
    volume_type = string
    volume_size = number
  })
  default = {
    volume_type = "gp2"
    volume_size = 30
  }
}
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
variable "vpn_server_allowed_ips" {
  type = list(string)
}
variable "vpn_keys_server_secret_name" {
  type = string
}
variable "vpn_keys_client_secret_name" {
  type = string
}