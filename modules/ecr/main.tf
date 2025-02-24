resource "aws_ecr_repository" "ecr" {
  name = var.repo_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}
