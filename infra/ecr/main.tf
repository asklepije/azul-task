resource "aws_ecr_repository" "ecr" {
  name = "task"
  tags = {
    Name = "task-ecr"
  }
}
