output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = var.key_name != "" ? "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_eip.bastion.public_ip}" : "Use AWS Systems Manager Session Manager to connect"
}
