resource "aws_eks_cluster" "eks" {
  count                     = var.enabled ? 1 : 0
  name                      = var.cluster_name
  version                   = var.k8s_version
  role_arn                  = aws_iam_role.eks.arn
  enabled_cluster_log_types = var.enabled_cluster_log_types
  tags                      = var.tags

  vpc_config {
    subnet_ids              = aws_subnet.eks[*].id
    endpoint_private_access = true
    endpoint_public_access  = false

    public_access_cidrs = []

    # List of security group IDs for the cross-account elastic network interfaces
    # that Amazon EKS creates to use to allow communication between your worker
    # nodes and the Kubernetes control plane.
    security_group_ids = var.security_group_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
  ]
}

resource "aws_iam_role" "eks" {
  name = "eks"
  path = "/${var.cluster_name}/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  tags              = var.tags
}
