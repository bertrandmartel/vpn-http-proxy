variable "prefix" {
  description = "naming prefix"
  type        = string
}
variable "aws_region" {
  type = string
}

variable "s3_kms_key_id" {
  description = "kms key id for encrypting S3 buckets"
  type        = string
}
variable "playbook_bucket_name" {
  description = "name of S3 bucket holding Ansible playbook"
  type        = string
}
variable "association_depends_on" {
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}

variable "vpn_server_secret" {}

variable "vpn_keys_server_secret_name" {
  type = string
}
variable "vpn_server_dns" {
  description = "VPN server domain name (vpn.example.com)"
}