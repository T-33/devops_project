terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# 2. Fetch the latest official Ubuntu 24.04 LTS AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (so EC2 can pull Docker images)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# 4. Upload your SSH Key to AWS
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-deployer-key"
  public_key = file(var.public_key_path)
}

# 5. EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Inject automated bootstrap script
  user_data = file("${path.module}/user-data.sh")

  root_block_device {
    volume_size = 10 # 10 GB disk
    volume_type = "gp3"
  }

  tags = {
    Name = "terraform-production-server"
  }
}

# 6. Allocate and Attach Elastic IP (Static IP)
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "web-elastic-ip"
  }
}
