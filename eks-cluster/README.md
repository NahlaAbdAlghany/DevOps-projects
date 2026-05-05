# EKS Cluster — Terraform

Provisions a production-ready Amazon EKS cluster on AWS using Terraform modules. Includes VPC networking, IAM roles, EKS add-ons with IRSA, remote state with locking, and control plane logging.

---

## Architecture

```
                          ┌─────────────────────────────────────────┐
                          │                  VPC                     │
                          │           10.0.0.0/16                    │
                          │                                          │
                          │  ┌──────────┐ ┌──────────┐ ┌─────────┐  │
                          │  │ Public   │ │ Public   │ │ Public  │  │
                          │  │ Subnet 0 │ │ Subnet 1 │ │ Subnet 2│  │
                          │  │ us-w-2a  │ │ us-w-2b  │ │ us-w-2c │  │
                          │  └────┬─────┘ └────┬─────┘ └────┬────┘  │
                          │       │             │            │       │
                          │  ┌────▼─────────────▼────────────▼────┐  │
                          │  │         EKS Node Group              │  │
                          │  │    3 × t3.medium worker nodes       │  │
                          │  └─────────────────────────────────────┘  │
                          │                   │                      │
                          └───────────────────┼──────────────────────┘
                                              │
                                    ┌─────────▼──────────┐
                                    │   Internet Gateway  │
                                    └─────────────────────┘

  Remote State
  ┌────────────────────┐     ┌──────────────────────┐
  │  S3 Bucket         │     │  DynamoDB Table       │
  │  terraform.tfstate │     │  terraform-state-lock │
  └────────────────────┘     └──────────────────────┘
```

---

## Project Structure

```
eks-cluster/
├── main.tf               # Root: wires vpc and eks modules together
├── variables.tf          # All input variables with defaults
├── outputs.tf            # Cluster endpoint, subnet IDs, OIDC ARN, etc.
├── provider.tf           # AWS provider + S3/DynamoDB remote backend
│
└── modules/
    ├── vpc/
    │   ├── vpc.tf        # VPC resource + AZ data source
    │   ├── subnets.tf    # Public subnets (one per AZ)
    │   ├── igw.tf        # Internet Gateway
    │   ├── routes.tf     # Route table + associations
    │   ├── sg.tf         # SSH security group for nodes
    │   ├── variables.tf  # vpc_cidr, subnet_count, ssh_cidr, cluster_name
    │   └── outputs.tf    # vpc_id, public_subnet_ids, node_ssh_sg_id
    │
    └── eks/
        ├── eks.tf        # EKS cluster, add-ons, OIDC provider
        ├── IAM.tf        # Cluster role, node role, EBS CSI role
        ├── nodes.tf      # Managed node group
        ├── local.tf      # Add-on maps (standard + IRSA)
        ├── variables.tf  # subnet_ids, cluster_name, scaling vars
        └── outputs.tf    # cluster_endpoint, ca_certificate, oidc_arn
```

---

## What Gets Created

### VPC Module
| Resource | Description |
|---|---|
| `aws_vpc` | VPC with DNS support and DNS hostnames enabled (both required by EKS) |
| `aws_subnet` (×3) | One public subnet per AZ — nodes receive public IPs directly |
| `aws_internet_gateway` | Allows internet traffic in/out of public subnets |
| `aws_route_table` | Routes all non-local traffic (`0.0.0.0/0`) to the IGW |
| `aws_security_group` | SSH security group attached to worker nodes |

### EKS Module
| Resource | Description |
|---|---|
| `aws_eks_cluster` | EKS control plane (Kubernetes 1.33) |
| `aws_eks_node_group` | Managed node group — 3 × t3.medium worker nodes |
| `aws_iam_role` (×3) | Cluster role, node role, EBS CSI role — all managed in Terraform |
| `aws_iam_openid_connect_provider` | OIDC provider enabling IRSA for add-ons |
| `aws_eks_addon` | vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver |

---

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | >= 1.5.0 |
| AWS CLI | >= 2.x |
| kubectl | >= 1.29 |

AWS credentials must be configured:
```bash
aws configure
# or
export AWS_PROFILE=your-profile
```

---

## Bootstrap Remote State (One-Time Setup)

The S3 bucket and DynamoDB table must exist before the first `terraform init`. Run these once:

```bash
# Create S3 bucket for state storage
aws s3api create-bucket \
  --bucket terraform-bucket-04052026 \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2

# Enable versioning so you can recover previous state files
aws s3api put-bucket-versioning \
  --bucket terraform-bucket-04052026 \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking (LockID is required as the partition key)
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

---

## Usage

### 1. Initialize
```bash
terraform init
```

### 2. Preview changes
```bash
terraform plan
```

### 3. Apply
```bash
terraform apply
```

### 4. Connect kubectl to the cluster
```bash
aws eks update-kubeconfig \
  --name $(terraform output -raw eks_cluster_name) \
  --region us-west-2
```

### 5. Verify nodes are ready
```bash
kubectl get nodes
```

---

## Input Variables

| Variable | Description | Default |
|---|---|---|
| `cluster_name` | EKS cluster name | `"my-cluster"` |
| `vpc_cidr` | CIDR block for the VPC | `"10.0.0.0/16"` |
| `subnet_count` | Number of public subnets (one per AZ) | `3` |
| `ssh_cidr` | CIDR allowed to SSH into nodes | `"0.0.0.0/0"` |
| `instance_type` | EC2 instance type for worker nodes | `"t3.medium"` |
| `desired_size` | Initial number of worker nodes | `3` |
| `min_size` | Minimum worker nodes (auto-scaling lower bound) | `1` |
| `max_size` | Maximum worker nodes (auto-scaling upper bound) | `3` |

Override any variable without editing code:
```bash
terraform apply \
  -var="cluster_name=prod-cluster" \
  -var="instance_type=t3.large" \
  -var="ssh_cidr=203.0.113.5/32"
```

Or create a `terraform.tfvars` file:
```hcl
cluster_name  = "prod-cluster"
instance_type = "t3.large"
ssh_cidr      = "203.0.113.5/32"
desired_size  = 2
min_size      = 1
max_size      = 5
```

---

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | VPC ID |
| `public_subnet_ids` | List of public subnet IDs |
| `eks_cluster_name` | EKS cluster name |
| `eks_cluster_endpoint` | API server endpoint URL |
| `eks_cluster_ca_certificate` | Base64 CA certificate (sensitive) |
| `oidc_provider_arn` | OIDC provider ARN for adding new IRSA roles |
| `eks_node_group_arn` | Node group ARN |

---

## IAM Roles

All three IAM roles are created and managed by Terraform — no manual console setup needed.

| Role | Assumed By | Purpose |
|---|---|---|
| `eksClusterRole` | `eks.amazonaws.com` | EKS control plane manages VPC ENIs, EC2 metadata |
| `AmazonEKSNodeRole` | `ec2.amazonaws.com` | Nodes pull images from ECR, register with cluster, allocate pod IPs |
| `AmazonEKS_EBS_CSI_Role` | EBS CSI service account (via OIDC/IRSA) | Create and attach EBS volumes as PersistentVolumes |

---

## EKS Add-ons

| Add-on | IRSA | Purpose |
|---|---|---|
| `vpc-cni` | No | Assigns VPC IPs to pods |
| `coredns` | No | In-cluster DNS — resolves Service names |
| `kube-proxy` | No | Maintains iptables rules for Service routing on each node |
| `aws-ebs-csi-driver` | Yes | Manages EBS volumes as Kubernetes PersistentVolumes |

---

## Destroy

Before running `terraform destroy`, always delete Kubernetes-managed AWS resources first. Otherwise, load balancers and ENIs created by Kubernetes will block VPC deletion.

```bash
# 1. Delete all LoadBalancer services (triggers ELB deletion in AWS)
kubectl delete svc --all -A

# 2. Wait ~30 seconds for ELBs to be deprovisioned
sleep 30

# 3. Destroy all Terraform-managed resources
terraform destroy
```

---

## Security Notes

- **SSH CIDR**: default is `0.0.0.0/0` (open). Set `ssh_cidr` to your IP in production.
- **EKS endpoint**: private access is enabled (`endpoint_private_access = true`). Public access is also on for kubectl convenience — disable it if you have a VPN or bastion host.
- **Control plane logs**: API, audit, and authenticator logs are sent to CloudWatch for traceability.
- **State file**: encrypted at rest in S3 (`encrypt = true`). Contains sensitive values — never commit it to git.
