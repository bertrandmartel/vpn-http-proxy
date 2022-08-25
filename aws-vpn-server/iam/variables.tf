variable "s3_policy" {}
variable "vpn_policy_server" {}
variable "prefix" {
  description = "objects prefix"
  default     = "prod"
}
variable "permissions_boundary" {
  description = "permission boundary arn to create IAM role"
  default     = null
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}