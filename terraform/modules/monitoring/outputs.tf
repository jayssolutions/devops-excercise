output "prometheus_url" {
  description = "URL of the Prometheus UI"
  value       = "http://${aws_instance.prometheus.public_ip}:9090"
}
