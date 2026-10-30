# Latest Ubuntu 24.04 LTS AMI published by Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use the account's default VPC so the demo needs no extra networking
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow SSH and HTTP for the Terraform demo"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-web-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = var.volume_size_gb
    volume_type = "gp3"
  }

  # Installs nginx and writes a page that proves Terraform provisioned this host
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    cat > /var/www/html/index.html <<'HTML'
    <html><body style="font-family:sans-serif;max-width:560px;margin:60px auto">
    <h1>Provisioned with Terraform</h1>
    <p>Project: ${var.project_name}</p>
    <p>Instance type: ${var.instance_type}</p>
    </body></html>
    HTML
    systemctl enable --now nginx
  EOF

  tags = {
    Name    = "${var.project_name}-web"
    Project = var.project_name
  }
}
