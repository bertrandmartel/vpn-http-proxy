variable "vpc_id" {
  description = "The VPC ID to deploy vpn server to"
}
variable "prefix" {
  description = "objects prefix"
  default     = "prod"
}
variable "permissions_boundary" {
  description = "permission boundary arn to create IAM role"
  default     = null
}
variable "ec2_ami" {
  description = "VPN server AMI Amazon Linux 2"
}
variable "ec2_instance_type" {
  description = "VPN server EC2 instance type"
  default     = "t2.medium"
}
variable "private_subnet" {
  type        = string
  description = "The private subnet to deploy to"
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}

variable "root_block_volume_config" {
  description = "config of the root volume of VPN server EC2 instance"
  type = object({
    volume_type = string
    volume_size = number
  })
  default = {
    volume_type = "gp2"
    volume_size = 30
  }
}

variable "ca_cert_md5" {
  type = string
}
variable "public_cert_md5" {
  type = string
}
variable "private_cert_md5" {
  type = string
}
variable "vpn_client" {
  type = bool
}
variable "instance_profile" {}

variable "security_group_id" {
  type = string
}
variable "playbook_sha" {
  type = string
}
variable "ssm_doc_sha" {
  type = string
}