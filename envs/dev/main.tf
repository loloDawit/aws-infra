terraform {
  backend "s3" {
    bucket         = "expense-tracker-terraform-state"  # ✅ Ensure it matches the bootstrap step
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "expense-tracker-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2"
}

module "backend" {
  source              = "../../modules/backend"
  project_name        = "expense-tracker"  # ✅ Prefix to ensure uniqueness
}

module "vpc" {
  source   = "../../modules/vpc"
  vpc_name = "eks-vpc"
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
}

module "ecr" {
  source    = "../../modules/ecr"
  repo_name = "expense-tracker"
}
