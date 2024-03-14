output "ecr_repository" {
  value = aws_ecr_repository.ecr.repository_url
}
