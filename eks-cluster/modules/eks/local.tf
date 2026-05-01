locals {
  eks_addons = {
    vpc_cni = {
      version = "latest"
    }
    coredns = {
      version = "latest"
    }
    kube_proxy = {}
    ebs_csi = {}
  }
}