module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source     = "./modules/eks"
  subnet_ids = module.vpc.public_subnet_ids
  node_role_arn = "arn:aws:iam::852405188872:role/AmazonEKSNodeRole"

  node_ssh_security_group_id = module.vpc.node_ssh_sg_id
}