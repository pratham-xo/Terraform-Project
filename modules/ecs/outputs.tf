output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}