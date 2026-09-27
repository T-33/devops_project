output "server_public_ip" {
  description = "The permanent Elastic IP of the server"
  value       = aws_eip.web_eip.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the server"
  value       = "ssh ubuntu@${aws_eip.web_eip.public_ip}"
}
