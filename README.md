# Terraform EC2 Grafana Setup

Este repositório utiliza Terraform para provisionar uma instância EC2 com Docker e Grafana. Além disso, usa GitHub Actions para automatizar o processo de deploy.

## Como rodar

1. Clone o repositório.
2. Defina suas credenciais AWS no GitHub Secrets.
3. Faça um push para a branch `main`, que irá automaticamente rodar o GitHub Actions e provisionar a EC2.

## GitHub Secrets necessários

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `EC2_SSH_PRIVATE_KEY`
teste