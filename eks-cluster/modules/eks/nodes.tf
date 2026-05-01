

resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster_name
  node_group_name = "worker-nodes"
  node_role_arn   = "arn:aws:iam::852405188872:role/AmazonEKSNodeRole"
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key               = "eks-cluster" 
    source_security_group_ids = [var.node_ssh_security_group_id]
  }

  
  depends_on = [
    aws_eks_cluster.cluster
  ]
}