output "next_steps" {
  value = "Please install Gateway VPN client or run it locally: openvpn --cd ${path.cwd}/test-config --config ${path.cwd}/test-config/test.conf"
}