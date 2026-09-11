data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_key_pair" "monitoring" {
  key_name   = "${var.project_name}-monitoring-key"
  public_key = trimspace(var.public_key)
}

resource "aws_security_group" "prometheus" {
  name   = "${var.project_name}-prometheus-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prometheus" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.monitoring.key_name
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.prometheus.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    prometheus_yml = templatefile("${path.module}/templates/prometheus.yml.tpl", {
      targets = var.app_targets
    })
    alerts_yml = file("${path.module}/templates/alerts.yml")
  })

  tags = {
    Name = "${var.project_name}-prometheus"
    Role = "monitoring"
  }
}
