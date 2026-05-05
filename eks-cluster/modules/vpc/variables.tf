variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of public subnets to create (one per AZ)"
  type        = number
  default     = 3
}

variable "ssh_cidr" {
  description = "CIDR block allowed to SSH into worker nodes"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cluster_name" {
  description = "EKS cluster name — used in subnet tags so the cluster can discover subnets"
  type        = string
}
