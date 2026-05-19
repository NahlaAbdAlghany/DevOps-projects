locals {
  # All standard EKS addons. Pod Identity handles IAM — no service_account_role_arn needed here.
  # vpc-cni:              AWS VPC CNI plugin — assigns VPC IPs to pods
  # coredns:              in-cluster DNS server — resolves Service names to ClusterIPs
  # kube-proxy:           maintains iptables rules for Service routing on each node
  # eks-pod-identity-agent: DaemonSet that intercepts credential requests from pods and
  #                         returns short-lived STS credentials for the associated IAM role
  # aws-ebs-csi-driver:   manages EBS volumes as Kubernetes PersistentVolumes
  eks_addons = {
    vpc-cni                = {}
    coredns                = {}
    kube-proxy             = {}
    eks-pod-identity-agent = {}
    aws-ebs-csi-driver     = {}
  }
}
