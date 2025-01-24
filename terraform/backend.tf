terraform {
  backend "s3" {
    bucket         = "jgpjuniorj-sa-east-1-terraform-statefile"
    key            = "env:/dev/terraform-aws-base"
    region         = "sa-east-1" # Adicione a região aqui
  }
}