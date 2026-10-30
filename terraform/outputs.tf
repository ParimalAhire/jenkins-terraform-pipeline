output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "URL of the page served by the instance"
  value       = "http://${aws_instance.web.public_ip}:${var.http_port}"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web.id
}
