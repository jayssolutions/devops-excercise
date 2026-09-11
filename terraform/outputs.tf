output "application_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "instance_public_ips" {
  value = module.compute.instance_public_ips
}

output "prometheus_url" {
  value = module.monitoring.prometheus_url
}

output "logging_public_ip" {
  value = module.logging.logging_public_ip
}

output "kibana_url" {
  value = module.logging.kibana_url
}
