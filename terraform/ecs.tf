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
  cpu                    = "1024"
  memory                 = "3072"
  execution_role_arn     = "arn:aws:iam::985539772981:role/ecsTaskExecutionRole"
  task_role_arn          = "arn:aws:iam::985539772981:role/ecsExecutionRole"
  container_definitions  = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.repo.repository_url}"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
        appProtocol   = "http"
        name          = "desafio-app-v2-80-tcp"
      }
    ]
  }])
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow traffic for ECS service"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 0
    to_port     = 65535
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

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  launch_type = "FARGATE"  # Garantir que o launch type seja FARGATE

  network_configuration {
    subnets          = [aws_subnet.public[0].id]
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true  # Permite atribuir IP público, se necessário
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