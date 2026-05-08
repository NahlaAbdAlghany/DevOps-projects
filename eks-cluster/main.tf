# ─── VPC Module ──────────────────────────────────────────────────────────────
# Creates: VPC, public subnets, IGW, route tables, SSH security group

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr     # CIDR for the whole VPC
  subnet_count = var.subnet_count # how many public subnets (one per AZ)
  ssh_cidr     = var.ssh_cidr     # who can SSH into worker nodes
  cluster_name = var.cluster_name # used for kubernetes.io/cluster/* subnet tags
}

# ─── EKS Module ──────────────────────────────────────────────────────────────
# Creates: EKS cluster, node group, IAM roles, OIDC provider, addons

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name

  # Subnets where nodes and the control plane ENIs will be placed
  subnet_ids = module.vpc.public_subnet_ids

  # Security group that allows SSH into nodes (created by vpc module)
  node_ssh_security_group_id = module.vpc.node_ssh_sg_id

  # Node group sizing
  instance_type = var.instance_type
  desired_size  = var.desired_size
  min_size      = var.min_size
  max_size      = var.max_size
}
