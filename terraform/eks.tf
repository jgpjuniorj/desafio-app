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

resource "aws_iam_policy" "eks_describe_cluster_policy" {
  # Nome da política que será criada
  name        = "eks_describe_cluster_policy"
  description = "Permissão para descrever o cluster EKS"
  
  # Definição da política em formato JSON (utilizando o jsonencode)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"  # Permissão para descrever o cluster EKS
        Resource = "arn:aws:eks:sa-east-1:985539772981:cluster/dev-cluster"  # ARN do seu cluster
      }
    ]
  })
}

