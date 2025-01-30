resource "aws_ecr_repository" "repo" {
  name = "desafio-app-v2"

  lifecycle {
    prevent_destroy = false  # Desativar para permitir a remoção
  }

  force_delete = true  # Permite excluir o repositório mesmo com imagens
}


resource "aws_ecs_cluster" "cluster" {
  name = "cluster-app"
}

resource "aws_ecs_task_definition" "task" {
  family                = "app"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                    = "2048"
  memory                 = "4096"
  execution_role_arn     = "arn:aws:iam::985539772981:role/ecsTaskExecutionRole"
  task_role_arn          = "arn:aws:iam::985539772981:role/ecsExecutionRole"
  container_definitions = jsonencode([
  {
    name      = "app"
    image     = "${aws_ecr_repository.repo.repository_url}"
    essential = true
    portMappings = [
      {
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }
    ]
  },
  {
    name      = "redirect"
    image     = "${aws_ecr_repository.repo.repository_url}"
    essential = true
    portMappings = [
      {
        containerPort = 5001
        hostPort      = 5001
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "TARGET_SERVICE"
        value = "http://localhost:5000"  # Defina o valor correto aqui
      }
    ]
  }
])
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow traffic for ECS service"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#subind serviço
resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 5000
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg-ip"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"  # Define o tipo de target como "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_iam_policy" "ecs_ecr_policy" {
  name        = "ecs_ecr_policy"
  description = "Allow ECS tasks to pull images from ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}