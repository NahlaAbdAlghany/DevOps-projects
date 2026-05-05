output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs — passed to the EKS module for node placement"
  value       = [for s in aws_subnet.public : s.id]
}

output "node_ssh_sg_id" {
  description = "Security group ID for SSH access — attached to the node group's remote_access block"
  value       = aws_security_group.node_ssh.id
}
