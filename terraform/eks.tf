module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "dev-cluster"
  cluster_version = "1.31"

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.public[0].id,  # Sub-rede na primeira AZ
    aws_subnet.public[1].id   # Sub-rede na segunda AZ
  ]


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}