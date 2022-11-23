output "instance" {
  description = "VPN EC2 instance"
  value       = aws_instance.vpn
}

output "public_ip" {
  description = "public IP"
  value = aws_eip.vpn.public_ip
}