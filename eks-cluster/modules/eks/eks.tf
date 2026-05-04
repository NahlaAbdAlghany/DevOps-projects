resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::852405188872:role/eksClusterRole"
  version  = "1.33"

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
}

resource "aws_eks_addon" "irsa" {
  for_each = local.eks_addons_with_irsa

  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = each.key
  service_account_role_arn = each.value.service_account_role_arn
}



data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}