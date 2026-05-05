# Route table for all public subnets.
# A route table controls where network traffic is directed.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "primary-eks-public-rt"
  }
}

# Default route: send all non-local traffic (0.0.0.0/0) to the Internet Gateway.
# This is what makes the subnets "public" — traffic can flow in and out via the IGW.
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate each public subnet with the public route table.
# Without this association, a subnet uses the VPC's default (local-only) route table.
resource "aws_route_table_association" "public_assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
