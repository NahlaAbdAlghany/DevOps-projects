# Public subnets — one per AZ for high availability.
# map_public_ip_on_launch: nodes receive a public IP directly (no NAT Gateway in this setup).
#
# Required tags for EKS subnet auto-discovery:
#   kubernetes.io/role/elb = "1"          → tells the AWS Load Balancer Controller
#                                           to place public-facing ELBs in these subnets
#   kubernetes.io/cluster/<name> = "shared" → marks the subnet as shared/usable by the cluster
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "primary-eks-public-subnet-${count.index}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
