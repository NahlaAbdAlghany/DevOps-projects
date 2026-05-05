locals {
  # Standard EKS addons that work with the node role's permissions — no dedicated IAM role needed.
  # vpc-cni:    AWS VPC CNI plugin — assigns VPC IPs to pods
  # coredns:    in-cluster DNS server — resolves Service names to ClusterIPs
  # kube-proxy: maintains iptables rules for Service routing on each node
  eks_addons = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }

  # Addons that use IRSA (IAM Roles for Service Accounts).
  # Each gets a dedicated role with only the permissions it needs (least privilege).
  # aws-ebs-csi-driver: manages EBS volumes as Kubernetes PersistentVolumes
  eks_addons_with_irsa = {
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_role.arn
    }
  }
}
