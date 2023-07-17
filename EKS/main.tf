data "aws_vpc" "eks_vpc" {
  id = var.vpc_id
}


data "aws_subnet_ids" "eks_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Terraform = "EKS"
  }

}

data "aws_iam_role" "eks_iam" {
  name = "${var.eks_iam_role}"
}