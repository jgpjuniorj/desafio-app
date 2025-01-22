resource "aws_security_group" "grafana_sg" {
  name        = "grafana-sg"
  description = "Allow inbound traffic on port 3000 (Grafana)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "grafana_key" {
  key_name   = "grafana_key_new"
  public_key = file("/mnt/c/key/grafana_key_new.pub")

}

resource "aws_instance" "grafana" {
  ami           = "ami-0c820c196a818d66a"  # Imagem Amazon Linux 2
  instance_type = "t3.micro"               # Free Tier

  key_name = aws_key_pair.grafana_key.key_name

  # Remover security_groups e usar apenas vpc_security_group_ids
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  subnet_id = aws_subnet.public[0].id
  
  # Corrigi duplicação da definição de tags
  tags = {
    Name = "Grafana EC2 Instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    # Atualizar o sistema
    yum update -y

    # Instalar Git
    yum install git -y

    # Instalar Docker
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user

    # Instalar Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Clonar o repositório com os arquivos do Grafana e Prometheus
    cd /home/ec2-user
    git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git grafana-setup
    cd grafana-setup

    # Rodar o Docker Compose
    docker-compose up -d
  EOF

}
