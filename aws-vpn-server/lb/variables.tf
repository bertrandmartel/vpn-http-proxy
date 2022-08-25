variable "public_subnets" {
  type        = list(any)
  description = "The public subnets to deploy to"
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}
variable "prefix" {
  description = "objects prefix"
  default     = "prod"
}
variable "security_group_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "instance_id" {
  type = string
}