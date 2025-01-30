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

module "eks_node_group" {
  source          = "terraform-aws-modules/eks/aws//modules/node-group"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version
  node_group_name = "app-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.public[*].id

  instance_types  = ["t3.micro"]
  desired_capacity = 2
  max_capacity     = 3
  min_capacity     = 1

  ami_type = "AL2_x86_64"

  labels = {
    Environment = "dev"
  }

  tags = {
    Name = "app-node-group"
  }
}
