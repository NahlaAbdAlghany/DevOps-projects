# Worker node group — the EC2 instances that run your pods.
resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster_name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn # managed in IAM.tf — no hardcoded ARN
  subnet_ids      = var.subnet_ids

  # Auto-scaling boundaries — desired_size is the initial count.
  # The Cluster Autoscaler (if installed) adjusts within min/max based on pod demand.
  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.instance_type]

  # Enables SSH access to nodes for debugging.
  # source_security_group_ids restricts which hosts can initiate SSH connections.
  remote_access {
    ec2_ssh_key               = "eks-cluster"
    source_security_group_ids = [var.node_ssh_security_group_id]
  }

  # Wait for the cluster and all node role policies to be fully ready before
  # creating nodes. IAM changes take a few seconds to propagate globally;
  # without this, node registration can fail with permission errors.
  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
