output "instance_public_ips" {
  description = "Public IP addresses of application instances"
  value       = aws_instance.app[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of application instances"
  value       = aws_instance.app[*].private_ip
}