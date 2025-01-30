resource "aws_ecr_repository" "my_repo" {
  name = "desafio-app-v2"

  lifecycle {
    prevent_destroy = false  # Desativar para permitir a remoção
  }

  force_delete = true  # Permite excluir o repositório mesmo com imagens
}


resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family                = "my-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                    = "256"
  memory                 = "512"
  execution_role_arn     = aws_iam_role.ecs_execution_role.arn  # Adicionando o role de execução
  container_definitions  = jsonencode([{
    name      = "my-app"
    image     = "${aws_ecr_repository.my_repo.repository_url}:latest"
    essential = true
    portMappings = [
      {
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }
    ]
  }])
}

resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
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

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1

  launch_type = "FARGATE"  # Garantir que o launch type seja FARGATE

  network_configuration {
    subnets          = [aws_subnet.public[0].id]
    security_groups = [aws_security_group.my_sg.id]
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