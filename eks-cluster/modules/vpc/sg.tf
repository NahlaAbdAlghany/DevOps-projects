# Security group attached to worker nodes to allow SSH access for debugging.
# This SG is referenced in the node group's remote_access block.
resource "aws_security_group" "node_ssh" {
  name   = "allow_ssh_to_nodes"
  vpc_id = aws_vpc.main.id

  # Allow inbound SSH from the specified CIDR.
  # In production, replace ssh_cidr with your specific IP (e.g. "203.0.113.5/32").
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Allow all outbound traffic — needed for nodes to reach AWS APIs,
  # download container images, and communicate with the control plane.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
