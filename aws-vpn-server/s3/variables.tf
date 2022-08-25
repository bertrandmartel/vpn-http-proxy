variable "prefix" {
  description = "naming prefix"
}
variable "common_tags" {
  default     = {}
  description = "common resource tags"
  type        = map(string)
}