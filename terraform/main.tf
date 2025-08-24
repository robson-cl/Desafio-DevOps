# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.app_name}-vpc" }
}

# 2. Subnets públicas
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.app_name}-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "${var.app_name}-subnet-b" }
}

# 3. Internet Gateway + Route Table
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.app_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${var.app_name}-rt" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# 4. Security Group
resource "aws_security_group" "ecs_sg" {
  name   = "${var.app_name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-sg" }
}

# 5. ECR Repository
resource "aws_ecr_repository" "repo" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = var.app_name }
}

resource "aws_ecr_repository" "nginx_repo" {
  name                 = "nginx-proxy"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "nginx-proxy" }
}

# 6. ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name = var.app_name
  tags = { Name = var.app_name }
}

# 7. IAM Role para ECS Task Execution
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 8. ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.app_name
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = var.container_port, hostPort = var.container_port }
      ]
    }
  ])
}

# 9. ECS Fargate Service
#resource "aws_ecs_service" "service" {
#  name            = var.app_name
#  cluster         = aws_ecs_cluster.ecs.id
#  task_definition = aws_ecs_task_definition.task.arn
#  desired_count   = var.desired_count
#  launch_type     = "FARGATE"
#
#  network_configuration {
#    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
#    security_groups = [aws_security_group.ecs_sg.id]
#    assign_public_ip = true
#  }
#
#  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
#}

# 10. criação do ALB e do target group
#resource "aws_security_group" "alb_sg" {
#  name   = "${var.app_name}-alb-sg"
#  vpc_id = aws_vpc.main.id
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = { Name = "${var.app_name}-alb-sg" }
#}
#
# ALB
resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false
  tags = { Name = "${var.app_name}-alb" }
}

# Target Group
#resource "aws_lb_target_group" "app_tg" {
#  name     = "${var.app_name}-tg"
#  port     = var.container_port
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.main.id
#  target_type = "ip"
#  health_check {
#    path                = "/health"
#    interval            = 30
#    timeout             = 5
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#    matcher             = "200-399"
#  }
#}
#
## Listener
#resource "aws_lb_listener" "app_listener" {
#  load_balancer_arn = aws_lb.app_alb.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.app_tg.arn
#  }
#}
#
## Adicionar dependência do ECS Service no Target Group
#resource "aws_ecs_service" "service" {
#  name            = var.app_name
#  cluster         = aws_ecs_cluster.ecs.id
#  task_definition = aws_ecs_task_definition.task.arn
#  desired_count   = var.desired_count
#  launch_type     = "FARGATE"
#
#  network_configuration {
#    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
#    security_groups = [aws_security_group.ecs_sg.id]
#    assign_public_ip = true
#  }
#
#  load_balancer {
#    target_group_arn = aws_lb_target_group.app_tg.arn
#    container_name   = var.app_name
#    container_port   = var.container_port
#  }
#
#  depends_on = [
#    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
#    aws_lb_listener.app_listener
#  ]
#}


# 1. Security Group do ALB
resource "aws_security_group" "alb_sg" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-alb-sg" }
}

# 2. Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# 3. Listener HTTP (usando ARN já existente)
resource "aws_lb_listener" "app_listener_https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn   = "arn:aws:acm:us-east-1:677459038746:certificate/fd19549a-3b43-4d08-bfd3-9b207e6efe23"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. (opcional) Listener HTTP -> HTTPS
resource "aws_lb_listener" "app_listener_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 5. ECS Service
resource "aws_ecs_service" "service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_lb_listener.app_listener_https
  ]
}
