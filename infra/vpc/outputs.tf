output "subnet_id" {
  value = aws_subnet.public_subnets.*.id
}

output "vpc_security_group_ids" {
  value = aws_security_group.security_group.id
}
output "security_group" {
  value = aws_security_group.security_group.id
}
