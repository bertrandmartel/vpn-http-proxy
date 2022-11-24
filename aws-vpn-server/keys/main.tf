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

data "local_sensitive_file" "gateway_client_public_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/issued/gateway_client.crt"
}
data "local_sensitive_file" "gateway_client_private_cert" {
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/private/gateway_client.key"
}
# copy gateway certificate to gateway-config directory
resource "local_sensitive_file" "gateway_ca_cert" {
  content         = data.local_sensitive_file.ca_cert.content
  filename        = "${path.module}/../../gateway-config/ca.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "gateway_public_cert" {
  content         = data.local_sensitive_file.gateway_client_public_cert.content
  filename        = "${path.module}/../../gateway-config/client.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "gateway_private_cert" {
  content         = data.local_sensitive_file.gateway_client_private_cert.content
  filename        = "${path.module}/../../gateway-config/client.key"
  file_permission = "0644"
}

# gateway client configuration file
data "template_file" "client_config" {
  template = file("${path.module}/../client.conf.tfpl")
  vars = {
    vpn_server_dns = var.vpn_server_dns
  }
}
resource "local_sensitive_file" "gateway_config" {
  content         = data.template_file.client_config.rendered
  filename        = "${path.module}/../gateway-config/client.conf"
  file_permission = "0644"
}
data "local_sensitive_file" "ccd_client" {
  filename        = "${path.module}/../ccd-client"
}

data "local_sensitive_file" "cert_files" {
  for_each = toset(var.vpn_clients)
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/issued/${each.key}.crt"
}
data "local_sensitive_file" "key_files" {
  for_each = toset(var.vpn_clients)
  filename = "${path.module}/../../easy-rsa/easy-rsa-src/pki/private/${each.key}.key"
}
resource "local_sensitive_file" "test_ca_cert" {
  for_each        = toset(var.vpn_clients)
  content         = data.local_sensitive_file.ca_cert.content
  filename        = "${path.module}/../../client-config/${each.key}/ca.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "public_cert" {
  for_each        = toset(var.vpn_clients)
  content         = data.local_sensitive_file.cert_files[each.key].content
  filename        = "${path.module}/../../client-config/${each.key}/client.crt"
  file_permission = "0644"
}
resource "local_sensitive_file" "private_cert" {
  for_each        = toset(var.vpn_clients)
  content         = data.local_sensitive_file.key_files[each.key].content
  filename        = "${path.module}/../../client-config/${each.key}/client.key"
  file_permission = "0644"
}
resource "local_sensitive_file" "client_config" {
  for_each        = toset(var.vpn_clients)
  content         = data.template_file.client_config.rendered
  filename        = "${path.module}/../../client-config/${each.key}/client.conf"
  file_permission = "0644"
}
resource "local_sensitive_file" "client_ccd" {
  for_each        = toset(var.vpn_clients)
  content         = data.local_sensitive_file.ccd_client.content
  filename        = "${path.module}/../playbook/roles/vpn_server/files/ccd/${each.key}"
  file_permission = "0644"
}