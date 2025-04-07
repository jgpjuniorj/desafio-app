resource "aws_efs_file_system" "grafana_efs" {
  creation_token = "grafana-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "efs_mt" {
  for_each        = toset(aws_subnet.public[*].id) # Subnets públicas onde o ECS está
  file_system_id  = aws_efs_file_system.grafana_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

# Access Point

resource "aws_efs_access_point" "grafana_ap" {
  file_system_id = aws_efs_file_system.grafana_efs.id

  posix_user {
    uid = 472 # Usuário padrão do Grafana
    gid = 472 # Grupo padrão do Grafana
  }

  root_directory {
    path = "/grafana"
    creation_info {
      owner_uid   = 472
      owner_gid   = 472
      permissions = "755"
    }
  }
}

# SG
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS traffic from ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Permite tráfego do SG do ECS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Permissão efs

resource "aws_iam_policy" "efs_policy" {
  name        = "efs_policy"
  description = "Permissões para acessar o EFS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Effect   = "Allow",
        Resource = aws_efs_file_system.grafana_efs.arn
      }
    ]
  })
}

# Anexe a política ao role de execução do ECS
resource "aws_iam_role_policy_attachment" "ecs_exec_efs" {
  role       = "ecsExecutionRole" # Nome do role existente
  policy_arn = aws_iam_policy.efs_policy.arn
}