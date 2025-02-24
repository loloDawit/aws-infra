resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

# ✅ Public Subnets (Auto-assign Public IPs)
resource "aws_subnet" "eks_public_subnets" {
  count             = 3
  vpc_id           = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(["us-west-2a", "us-west-2b", "us-west-2c"], count.index)
  
  map_public_ip_on_launch = true  # ✅ Enable auto-assign public IP

  tags = {
    Name = "eks-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

# ✅ Private Subnets (No Public IPs)
resource "aws_subnet" "eks_private_subnets" {
  count             = 3
  vpc_id           = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"  # ✅ Avoid overlapping CIDR blocks
  availability_zone = element(["us-west-2a", "us-west-2b", "us-west-2c"], count.index)

  tags = {
    Name = "eks-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ✅ Internet Gateway for Public Subnets
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

# ✅ Public Route Table
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.eks_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

resource "aws_route_table_association" "eks_public_subnet_association" {
  count         = length(aws_subnet.eks_public_subnets)
  subnet_id     = aws_subnet.eks_public_subnets[count.index].id
  route_table_id = aws_route_table.eks_public_route_table.id
}

# ✅ NAT Gateway for Private Subnets
resource "aws_eip" "eks_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.eks_public_subnets[0].id
}

# ✅ Private Route Table
resource "aws_route_table" "eks_private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = aws_route_table.eks_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat.id
}

resource "aws_route_table_association" "eks_private_subnet_association" {
  count = length(aws_subnet.eks_private_subnets)
  subnet_id      = aws_subnet.eks_private_subnets[count.index].id
  route_table_id = aws_route_table.eks_private_route_table.id
}

# ✅ Outputs
output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.eks_public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.eks_private_subnets[*].id
}
