variable "image_version" {
  type    = string
  default = "latest"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "task-cluster"
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name = "task-iam-role"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name = "task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "policy" {
  name = "task-s3-policy"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : "arn:aws:s3:::asklepijes.com/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/task"
}

resource "aws_ecs_task_definition" "task_definition" {
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  family                   = "task"
  container_definitions = jsonencode([{
    name : "task",
    image : "${var.ecr_repository}:${var.image_version}",
    essential : true,
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = "us-east-1",
        "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
        "awslogs-stream-prefix" = formatdate("YYYY-MM-DD", timestamp())
      }
    },
  }])
  lifecycle {
    ignore_changes = all
  }

}
