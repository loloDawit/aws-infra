variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}


variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "expense-tracker-cluster"
}
