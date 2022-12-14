output "vpn_server_secret" {
  value = aws_secretsmanager_secret.vpn_keys_server_secret
}
output "ca_cert_md5" {
  value = md5(data.local_sensitive_file.ca_cert.content)
}
output "server_public_md5" {
  value = md5(data.local_sensitive_file.server_public_cert.content)
}
output "server_private_md5" {
  value = md5(data.local_sensitive_file.server_private_cert.content)
}
