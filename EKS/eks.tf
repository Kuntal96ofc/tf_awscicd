data "aws_eks_cluster" "eks_gs" {
  name = "getting-started-eks"
}

resource "aws_eks_node_group" "eks_gs_ng" {
  cluster_name    = data.aws_eks_cluster.eks_gs.name
  node_group_name = "eks_additional_node_group"
  node_role_arn   = data.aws_iam_role.eks_iam.arn
  subnet_ids      = data.aws_subnet_ids.eks_subnet_ids.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}