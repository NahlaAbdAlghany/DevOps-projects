output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the EKS node group and load balancers"
  value       = module.vpc.public_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name — use with: aws eks update-kubeconfig --name <value>"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64) — needed for kubeconfig"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true # marked sensitive so it doesn't print in plain text during apply
}

output "eks_node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks.node_group_arn
}

output "cert_manager_role_arn" {
  description = "IAM Role ARN for cert-manager — this is the STS ARN to share with GCP Workload Identity Federation"
  value       = module.eks.cert_manager_role_arn
}
