output "vpc_id" {
  description = "ID da VPC criada."
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs das sub-redes públicas."
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs das sub-redes privadas."
  value       = aws_subnet.private[*].id
}


