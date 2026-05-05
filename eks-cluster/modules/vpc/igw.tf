# Internet Gateway — the VPC's door to the public internet.
# Required so that resources in public subnets can send/receive traffic from the internet.
# Without this, nodes cannot pull container images or reach AWS APIs.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "primary-eks-igw"
  }
}
