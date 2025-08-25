variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Nome da aplicação / cluster / repositório"
  default     = "desafio-devops"
}

variable "nginx_name" {
  description = "nginx nome"
  default     = "nginx-proxy"
}

variable "container_port" {
  default = 5000
}

variable "container_port_nginx" {
  description = "Porta do nginx"
  default     = 443
}

variable "desired_count" {
  description = "Número de tasks"
  default     = 1
}

variable "alb_port" {
  description = "Porta do ALB"
  default     = 443
}

variable "alb_health_check_path" {
  description = "Path de health check do ALB"
  default     = "/health"
}
