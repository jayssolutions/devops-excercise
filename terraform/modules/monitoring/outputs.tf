output "prometheus_url" {
  description = "URL of the Prometheus UI"
  value       = "http://${aws_instance.prometheus.public_ip}:9090"
}

output "prometheus_security_group_id" {
  description = "Security group ID attached to the Prometheus instance"
  value       = aws_security_group.prometheus.id
}