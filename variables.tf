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
