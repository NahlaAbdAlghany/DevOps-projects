resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::852405188872:role/eksClusterRole"

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_addon" "addons" {
  for_each = local.eks_addons

  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = each.key

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.cluster]
}