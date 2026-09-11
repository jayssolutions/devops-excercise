output "application_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "instance_public_ips" {
  value = module.compute.instance_public_ips
}

output "prometheus_url" {
  value = module.monitoring.prometheus_url
}
