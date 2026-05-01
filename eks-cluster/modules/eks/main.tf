# modules/eks/main.tf


# Security Group for SSH access
resource "aws_security_group" "node_ssh" {
  name        = "allow_ssh_to_nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs as requested
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::852405188872:role/eksClusterRole"

  vpc_config {
    subnet_ids = var.subnet_ids
  }


}



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
    source_security_group_ids = [aws_security_group.node_ssh.id]
  }

  
  depends_on = [
    aws_eks_cluster.cluster
  ]
}