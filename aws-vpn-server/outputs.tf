output "next_steps" {
  value = "Please install Gateway VPN client or run it locally: openvpn --cd ${path.cwd}/../gateway-config --config ${path.cwd}/../gateway-config/gateway.conf"
}