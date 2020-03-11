
data aws_eks_cluster "eks" {
  name = var.cluster_name
}

# See https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

resource "aws_iam_role" "eks-iam-service-account" {
  name               = var.role_name
  path               = "/${var.cluster_name}/"
  assume_role_policy = data.aws_iam_policy_document.eks-iam-service-account.json
}

resource "aws_iam_role_policy" "eks-iam-service-account" {
  role   = var.role_name
  policy = var.policy
}

data "aws_iam_policy_document" "eks-iam-service-account" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.eks.arn}"]
      type        = "Federated"
    }
  }
}
