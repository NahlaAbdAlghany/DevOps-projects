# ─── EKS Cluster ─────────────────────────────────────────────────────────────

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn # managed in IAM.tf — no hardcoded ARN
  version  = "1.33"

  vpc_config {
    subnet_ids = var.subnet_ids

    # endpoint_private_access: nodes communicate with the control plane over a private
    #   endpoint inside the VPC — traffic stays within AWS, not over the internet.
    # endpoint_public_access: keeps the kubectl API reachable from outside the VPC.
    #   In production with a VPN/bastion, set this to false.
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Control plane log types sent to CloudWatch Logs.
  # api:           all kubectl requests to the API server
  # audit:         who did what to which resource (important for security)
  # authenticator: IAM authentication events (useful for debugging auth failures)
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  # Ensure the cluster role and its policy are fully attached before creating the cluster.
  # Without this, the cluster creation can fail with an IAM propagation error.
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ─── EKS Addons ──────────────────────────────────────────────────────────────

# Standard addons that don't need a dedicated IAM role (no IRSA)
resource "aws_eks_addon" "addons" {
  for_each = local.eks_addons

  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = each.key

  # OVERWRITE lets Terraform re-apply addon config even if it was changed outside Terraform
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# Addons that use IRSA (IAM Roles for Service Accounts) for fine-grained AWS permissions.
# Each addon gets its own IAM role instead of relying on the broad node role.
resource "aws_eks_addon" "irsa" {
  for_each = local.eks_addons_with_irsa

  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = each.key
  service_account_role_arn = each.value.service_account_role_arn
}

# ─── OIDC Provider ───────────────────────────────────────────────────────────
# IRSA works by federating Kubernetes service accounts to IAM via OIDC.
# This block sets up the OIDC identity provider so AWS IAM trusts tokens
# issued by the EKS cluster's built-in OIDC endpoint.

data "tls_certificate" "eks" {
  # EKS exposes an OIDC issuer URL — we fetch its TLS cert thumbprint
  # so AWS can verify the identity of the token issuer
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}




