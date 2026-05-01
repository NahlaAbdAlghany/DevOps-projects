
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "node_ssh_sg_id" {
  value = aws_security_group.node_ssh.id
}

