output "cluster_name" {
  value = var.cluster_name
  description = "EKS cluster name"
}

output "node_group_name" {
  value = aws_eks_node_group.nodes.node_group_name
  description = "EKS node group name"
}

output "node_group_arn" {
  value = aws_eks_node_group.nodes.arn
  description = "EKS node group ARN"
}