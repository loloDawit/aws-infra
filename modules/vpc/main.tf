resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "eks_subnets" {
  count = 3  # ✅ Ensure at least two different AZs

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-west-2a", "us-west-2b", "us-west-2c"], count.index)  # ✅ Different AZs

  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.eks_subnets[*].id  # ✅ Ensures EKS gets all subnet IDs
}
