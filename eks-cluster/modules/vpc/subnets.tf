
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true 


  tags = {
    Name                                = "primary-eks-public-subnet-${count.index}"
    "kubernetes.io/role/elb"            = "1"               # Required for Public Load Balancers
    "kubernetes.io/cluster/my-cluster"  = "shared"          # Change 'my-cluster' to your actual cluster name
  }
}