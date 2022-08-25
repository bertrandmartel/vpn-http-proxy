variable "vpn_server_allowed_ips" {
  type = list(string)
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}
variable "vpc_id" {
  description = "The VPC ID to deploy vpn server to"
}
variable "prefix" {
  description = "objects prefix"
  default     = "prod"
}