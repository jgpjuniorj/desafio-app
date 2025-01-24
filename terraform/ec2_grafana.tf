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


resource "aws_instance" "grafana" {
  ami           = var.ami_id  # Imagem Amazon Linux 2
  instance_type = var.instance_type               # Free Tier

  key_name      = "grafana_key_git"

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
    sudo yum install git -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo usermod -a -G docker ssm-user
    sudo systemctl enable docker
    sudo systemctl start docker
  EOF
}


data "template_file" "grafana_private_key" {
  template = file("/home/runner/work/terraform-aws-base/terraform-aws-base/keys/grafana_key_git.pem")
}

# Recurso null_resource para executar provisioners
resource "null_resource" "grafana_provision" {
  depends_on = [aws_instance.grafana]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.template_file.grafana_private_key.rendered
      host        = aws_instance.grafana.public_ip
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
      "sudo yum install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo systemctl enable docker",
      "sudo systemctl start docker"
    ]
  }
}

