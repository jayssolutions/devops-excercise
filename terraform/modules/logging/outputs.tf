output "logging_public_ip" {
  description = "Public IP address of the ELK logging instance"
  value       = aws_instance.logging.public_ip
}

output "kibana_url" {
  description = "URL of the Kibana UI"
  value       = "http://${aws_instance.logging.public_ip}:5601"
}

output "logging_security_group_id" {
  description = "Security group ID attached to the logging instance"
  value       = aws_security_group.logging.id
}
