module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source     = "./modules/eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  
  node_role_arn = "arn:aws:iam::852405188872:role/AmazonEKSNodeRole"
}