# Output important information
output "instance_public_ip" {
  value = aws_instance.ansible_host.public_ip
}

output "instance_id" {
  value = aws_instance.ansible_host.id
}

output "ssh_command" {
  value = "ssh -i private_key.pem ubuntu@${aws_instance.ansible_host.public_ip}"
}