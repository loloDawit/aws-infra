resource "aws_eks_cluster" "eks" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "eks.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-managed-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

resource "aws_iam_role" "node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
