module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  alb_security_group = module.alb.alb_security_group_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
  instance_count     = var.instance_count
  admin_cidr         = var.admin_cidr
  public_key         = var.public_key
}

module "monitoring" {
  source            = "./modules/monitoring"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  admin_cidr        = var.admin_cidr
  public_key        = var.public_key
  app_targets       = [for ip in module.compute.instance_private_ips : "${ip}:3000"]
} 

# Allow Prometheus to scrape the app instances' /metrics endpoint
resource "aws_security_group_rule" "prometheus_scrape_app" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = module.compute.app_security_group_id
  source_security_group_id = module.monitoring.prometheus_security_group_id
  description              = "Prometheus scraping app /metrics"
}

module "logging" {
  source            = "./modules/logging"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  admin_cidr        = var.admin_cidr
  public_key        = var.public_key
}

# Allow app instances to ship logs (via Filebeat) to Logstash
resource "aws_security_group_rule" "logstash_ingest_from_app" {
  type                     = "ingress"
  from_port                = 5044
  to_port                  = 5044
  protocol                 = "tcp"
  security_group_id        = module.logging.logging_security_group_id
  source_security_group_id = module.compute.app_security_group_id
  description              = "Filebeat shipping app logs to Logstash"
}

# Create the S3 State Bucket
module "state" {
  source        = "./modules/s3"
  bucket_name   = "jays-devops-tf-state-bucket"
  force_destroy = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
} 