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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "grafana_key" {
  key_name   = "grafana-key"
  public_key = file("/mnt/c/Users/Jair_Junior/OneDrive - American Tower/Área de Trabalho/key/grafana-key.pub")
}

resource "aws_instance" "grafana" {
  ami           = "ami-0c820c196a818d66a"  # Imagem Amazon Linux 2
  instance_type = "t2.micro"               # Free Tier

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
              sudo yum update -y
              sudo amazon-linux-extras enable corretto8
              sudo yum install -y java-1.8.0-openjdk
              sudo yum install -y wget
              wget https://dl.grafana.com/oss/release/grafana-9.6.2-1.x86_64.rpm
              sudo yum install -y grafana-9.6.2-1.x86_64.rpm
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server
              EOF
}
