variable "aws_region" {
  description = "Região da AWS para criar os recursos."
  type        = string
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para sub-redes públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para sub-redes privadas."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI para a instância EC2"
  default     = "ami-0c820c196a818d66a"  # Exemplo de AMI Amazon Linux 2
}

variable "pem_file_path" {
  description = "Path to the PEM file for SSH"
  type        = string
}