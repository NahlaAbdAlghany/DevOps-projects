variable "vpc_id" {
  description = "The VPC ID from the network module"
  type        = string
}

variable "subnet_ids" {
  description = "The list of public subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-cluster"
}

variable "node_role_arn" {
  description = "ARN of the node IAM role"
  type        = string

}