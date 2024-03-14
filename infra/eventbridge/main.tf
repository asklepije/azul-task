resource "aws_iam_role" "ecs_event_role" {
  name = "ecs-event-role"
  assume_role_policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_event_role_policy_attachment" {
  role       = aws_iam_role.ecs_event_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_cloudwatch_event_rule" "hourly_task" {
  name                = "hourly-task-rule"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "hourly_task_target" {
  target_id = "hourly-task-target"
  rule      = aws_cloudwatch_event_rule.hourly_task.name
  arn       = var.cluster_arn
  role_arn  = aws_iam_role.ecs_event_role.arn

  ecs_target {
    task_definition_arn = var.task_definition_arn
    task_count          = 1
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    network_configuration {
      subnets          = var.subnet_ids
      assign_public_ip = true
      security_groups  = [var.security_group]
    }
  }
}
