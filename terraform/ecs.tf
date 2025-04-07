resource "aws_ecr_repository" "repo" {
  name = "desafio-app-v2"

  lifecycle {
    prevent_destroy = false
  }

  force_delete = true
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster-app"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = "arn:aws:iam::985539772981:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::985539772981:role/ecsExecutionRole"

  volume {
    name = "grafana-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.grafana_efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.grafana_ap.id
        iam             = "ENABLED"
      }
    }
  }

  # Volume para configuração do Prometheus
  volume {
    name = "prometheus-config-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.grafana_efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus_config_ap.id
        iam             = "ENABLED"
      }
    }
  }

  # Volume para os dados do Prometheus
  volume {
    name = "prometheus-data-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.grafana_efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus_data_ap.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name         = "grafana"
      image        = "grafana/grafana:11.3.0"
      essential    = true
      portMappings = [{ containerPort = 3000, hostPort = 3000, protocol = "tcp" }]
      mountPoints = [
        {
          sourceVolume  = "grafana-storage",
          containerPath = "/var/lib/grafana",
          readOnly      = false
        }
      ]
    },
    {
      name         = "prometheus"
      image        = "prom/prometheus:v3.1.0"
      essential    = true
      portMappings = [{ containerPort = 9090, hostPort = 9090, protocol = "tcp" }]
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus"
      ]
      mountPoints = [
        {
          sourceVolume  = "prometheus-config-storage",
          containerPath = "/etc/prometheus", # Ponto de montagem para a configuração
          readOnly      = false
        },
        {
          sourceVolume  = "prometheus-data-storage",
          containerPath = "/prometheus", # Ponto de montagem para os dados
          readOnly      = false
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
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
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
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }
}

resource "aws_iam_policy" "ecs_ecr_policy" {
  name        = "ecs_ecr_policy"
  description = "Allow ECS tasks to pull images from ECR"
  policy = jsonencode({
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
