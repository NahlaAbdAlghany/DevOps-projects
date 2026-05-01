output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID created by the vpc module"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs from the vpc module"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name (from eks module)"
}

output "eks_node_group_arn" {
  value       = module.eks.node_group_arn
  description = "EKS node group ARN (from eks module)"
}