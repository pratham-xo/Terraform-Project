output "alb_dns_name" {
  value = aws_lb.ALB.dns_name
}

output "alb_sg_name" {
  value = aws_security_group.alb_sg.id
}

output "target_group_alb" {
  value = aws_lb_target_group.aws_ecs_target_group.id
}