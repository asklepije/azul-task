variable "subnet_ids" {
  type = list(string)
}
variable "security_group" {
  type = string
}
variable "task_definition_arn" {
  type = string
}
variable "cluster_arn" {
  type = string
}
