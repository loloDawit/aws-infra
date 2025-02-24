terraform {
  backend "s3" {
    bucket         = "terraform-eks-state"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2"
}

module "backend" {
  source              = "../../modules/backend"  # ✅ Use correct relative path
  s3_bucket_name      = "terraform-eks-state"
  dynamodb_table_name = "terraform-locks"
}

module "vpc" {
  source   = "../../modules/vpc"  # ✅ Use correct relative path
  vpc_name = "eks-vpc"
}

module "eks" {
  source       = "../../modules/eks"  # ✅ Use correct relative path
  cluster_name = "expense-tracker-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
}

module "ecr" {
  source    = "../../modules/ecr"  # ✅ Use correct relative path
  repo_name = "expense-tracker"
}
