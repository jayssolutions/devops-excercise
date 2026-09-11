variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }

variable "admin_cidr" {
  description = "CIDR allowed to reach the Kibana UI and SSH"
  type        = string
}

variable "public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type for the ELK logging host (Elasticsearch + Logstash + Kibana together need more headroom than the app/monitoring instances)"
  type        = string
  default     = "t3.micro"
}
