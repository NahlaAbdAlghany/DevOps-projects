# Fetch all AZs that are currently available in the configured region.
# Used to spread subnets across AZs for high availability.
data "aws_availability_zones" "available" {
  state = "available"
}

# Main VPC for the EKS cluster.
# enable_dns_support and enable_dns_hostnames are both required by EKS:
#   - dns_support:    allows Route53 resolver to work inside the VPC
#   - dns_hostnames:  gives EC2 instances resolvable hostnames (needed by the kubelet)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "primary-eks-infrastructure-vpc"
  }
}
