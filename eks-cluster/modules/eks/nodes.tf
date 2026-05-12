# ─── General Worker Node Group ───────────────────────────────────────────────
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

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

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

# ─── ArgoCD Dedicated Node Group ─────────────────────────────────────────────
# ON_DEMAND only — ArgoCD drives all GitOps syncs; a spot interruption would
# stall deployments across every app until the node is replaced.
resource "aws_eks_node_group" "argocd" {
  cluster_name    = var.cluster_name
  node_group_name = "argocd-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.argocd_desired_size
    min_size     = var.argocd_min_size
    max_size     = var.argocd_max_size
  }

  capacity_type  = "ON_DEMAND"
  instance_types = [var.argocd_instance_type]

  # Label lets ArgoCD pods target this group via nodeSelector.
  labels = {
    role = "argocd"
  }

  # Taint repels every pod that doesn't explicitly tolerate it,
  # so general workloads never land on ArgoCD nodes.
  taint {
    key    = "dedicated"
    value  = "argocd"
    effect = "NO_SCHEDULE"
  }

  remote_access {
    ec2_ssh_key               = "eks-cluster"
    source_security_group_ids = [var.node_ssh_security_group_id]
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
