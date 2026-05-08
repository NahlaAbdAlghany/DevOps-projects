variable "subnet_ids" {
  description = "List of subnet IDs where the EKS control plane ENIs and worker nodes are placed"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-cluster"
}

variable "node_ssh_security_group_id" {
  description = "Security group ID that is allowed to SSH into worker nodes"
  type        = string
}

# ─── Node Group Sizing ────────────────────────────────────────────────────────

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Initial number of worker nodes to launch"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes (lower bound for auto-scaling)"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes (upper bound for auto-scaling)"
  type        = number
  default     = 3
}
