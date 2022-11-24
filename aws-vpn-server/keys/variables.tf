variable "vpn_keys_client_secret_name" {
  type = string
}
variable "vpn_keys_server_secret_name" {
  type = string
}
variable "vpn_server_dns" {
  type = string
}
variable "vpn_clients" {
  type        = list(any)
  description = "List of vpn client common name. This is the same list used in easy-rsa init-keys script"
}