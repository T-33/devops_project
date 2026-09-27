variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to your local SSH public key to log into EC2"
  type        = string
  default     = "~/.ssh/id_rsa.pub" 
}

