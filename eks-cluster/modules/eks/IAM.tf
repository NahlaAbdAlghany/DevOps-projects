# ─── EKS Cluster Role ────────────────────────────────────────────────────────
# The EKS control plane assumes this role to manage AWS resources on your behalf
# (e.g. creating ENIs in your VPC, describing EC2 instances).

resource "aws_iam_role" "eks_cluster_role" {
  name = "eksClusterRole"

  # Trust policy: only the EKS service can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Grants the cluster role the minimum permissions required to run EKS
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─── EKS Node Role ───────────────────────────────────────────────────────────
# Worker nodes (EC2 instances) assume this role to interact with AWS services:
#   - pulling images from ECR
#   - attaching ENIs for pod networking (VPC CNI)
#   - reading cluster info

resource "aws_iam_role" "eks_node_role" {
  name = "AmazonEKSNodeRole"

  # Trust policy: only EC2 instances can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Allows nodes to connect to the EKS cluster and register themselves
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Allows the VPC CNI plugin to allocate IPs for pods from the VPC CIDR
resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Allows nodes to pull container images from ECR (Elastic Container Registry)
resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ─── EBS CSI Role ────────────────────────────────────────────────────────────
# The EBS CSI driver uses IRSA (IAM Roles for Service Accounts) so only its
# specific Kubernetes service account can assume this role — not the whole node.
# This is more secure than attaching EBS permissions directly to the node role.

resource "aws_iam_role" "ebs_csi_role" {
  name = "AmazonEKS_EBS_CSI_Role"

  # Trust policy: only the ebs-csi-controller-sa service account (via OIDC) can assume this
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

# Grants the EBS CSI role permissions to create, attach, and delete EBS volumes
resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
