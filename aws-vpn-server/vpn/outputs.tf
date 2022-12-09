output "instance" {
  description = "VPN EC2 instance"
  value       = aws_instance.vpn
}

output "public_ip" {
  description = "public IP"
  value = var.is_public ? aws_eip.vpn[0].public_ip : null
}