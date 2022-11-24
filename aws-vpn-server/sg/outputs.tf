output "vpn_server_sg" {
  description = "VPN server security group"
  value       = aws_security_group.vpn_server
}