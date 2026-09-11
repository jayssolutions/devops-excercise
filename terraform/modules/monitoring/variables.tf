variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }

variable "admin_cidr" {
  description = "CIDR allowed to reach the Prometheus UI and SSH"
  type        = string
}

variable "public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_targets" {
  description = "List of \"ip:port\" scrape targets for the application's /metrics endpoint"
  type        = list(string)
}
