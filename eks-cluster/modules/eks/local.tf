locals {
  eks_addons = {
    vpc-cni = {}
    coredns = {}
    kube-proxy = {}
  }

   eks_addons_with_irsa = {
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_role.arn
    }
  }
}
