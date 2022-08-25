data "local_sensitive_file" "ca_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/ca.crt"
}
data "local_sensitive_file" "server_public_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/issued/vpn1.crt"
}
data "local_sensitive_file" "server_private_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/private/vpn1.key"
}
data "local_sensitive_file" "server_dh" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/dh2048.pem"
}
data "local_sensitive_file" "gateway_client_public_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/issued/gateway_client.crt"
}
data "local_sensitive_file" "gateway_client_private_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/private/gateway_client.key"
}
data "local_sensitive_file" "aws_client_public_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/issued/aws_client.crt"
}
data "local_sensitive_file" "aws_client_private_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/private/aws_client.key"
}

resource "aws_secretsmanager_secret" "vpn_keys_client_secret" {
  name                    = var.vpn_keys_client_secret_name
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "vpn_keys_client_secret" {
  secret_id = aws_secretsmanager_secret.vpn_keys_client_secret.id
  secret_string = jsonencode({
    "ca_cert"      = base64encode(data.local_sensitive_file.ca_cert.content)
    "public_cert"  = base64encode(data.local_sensitive_file.aws_client_public_cert.content)
    "private_cert" = base64encode(data.local_sensitive_file.aws_client_private_cert.content)
  })
}

resource "aws_secretsmanager_secret" "vpn_keys_server_secret" {
  name                    = var.vpn_keys_server_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "vpn_keys_server_secret" {
  secret_id = aws_secretsmanager_secret.vpn_keys_server_secret.id
  secret_string = jsonencode({
    "ca_cert"      = base64encode(data.local_sensitive_file.ca_cert.content)
    "public_cert"  = base64encode(data.local_sensitive_file.server_public_cert.content)
    "private_cert" = base64encode(data.local_sensitive_file.server_private_cert.content)
    "dh"           = base64encode(data.local_sensitive_file.server_dh.content)
  })
}

# copy gateway certificate to gateway-config directory
resource "local_sensitive_file" "gateway_ca_cert" {
  content         = data.local_sensitive_file.ca_cert.content
  filename        = "${path.module}/../../gateway-config/ca.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "gateway_public_cert" {
  content         = data.local_sensitive_file.gateway_client_public_cert.content
  filename        = "${path.module}/../../gateway-config/gateway.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "gateway_private_cert" {
  content         = data.local_sensitive_file.gateway_client_private_cert.content
  filename        = "${path.module}/../../gateway-config/gateway.key"
  file_permission = "0644"
}

