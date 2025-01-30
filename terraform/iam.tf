resource "aws_iam_policy_attachment" "attach_eks_describe_policy" {
  # Nome da anexação da política
  name       = "attach_eks_describe_policy"
  
  # ARN da política criada acima
  policy_arn = aws_iam_policy.eks_describe_cluster_policy.arn
  
  # Definindo o usuário ao qual a política será anexada
  users      = ["tf"]  # Nome do usuário IAM que você deseja conceder a permissão
}
