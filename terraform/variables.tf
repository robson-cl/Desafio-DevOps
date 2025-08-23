variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Nome da aplicação / cluster / repositório"
  default     = "desafio-devops"
}

variable "container_port" {
  description = "Porta da aplicação"
  default     = 5000
}

variable "desired_count" {
  description = "Número de tasks"
  default     = 1
}
