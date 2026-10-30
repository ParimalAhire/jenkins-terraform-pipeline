variable "aws_region" {
  description = "AWS region to create resources in (use the same region as your console)"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix used for every resource and tag"
  type        = string
  default     = "iac-demo"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (use your own IP, for example 203.0.113.10/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "http_port" {
  description = "Port where the web server is reachable"
  type        = number
  default     = 80
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH. Leave null to skip."
  type        = string
  default     = null
}

variable "volume_size_gb" {
  description = "Root volume size in GiB"
  type        = number
  default     = 8
}
