output "task_definition_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}
output "cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster.arn
}
