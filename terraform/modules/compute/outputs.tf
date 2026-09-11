output "instance_public_ips" {
  description = "Public IP addresses of application instances"
  value       = aws_instance.app[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of application instances"
  value       = aws_instance.app[*].private_ip
}

output "app_security_group_id" {
  description = "Security group ID attached to the application instances"
  value       = aws_security_group.app.id
}