aws_region = "sa-east-1"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

instance_type = "t3.micro"

ami_id = "ami-0c820c196a818d66a"  # Exemplo de AMI Amazon Linux 2

pem_file_path = "./keys/grafana_key_git.pem"

