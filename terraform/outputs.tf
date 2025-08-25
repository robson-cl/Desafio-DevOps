output "ecr_repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs.name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.app_alb.arn
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.nginx_tg.arn
}
variable "nginx_desired_count" {
  description = "Número de tasks do Nginx"
  default     = 1
}