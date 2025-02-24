variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "eks-cluster"
}

variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS cluster"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnets for EKS cluster nodes"
  type        = list(string)
}
