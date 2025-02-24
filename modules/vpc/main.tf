resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name  # ✅ Use the variable to name the VPC
  }
}

resource "aws_subnet" "eks_subnets" {
  count = 3
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.eks_subnets[*].id
}
