resource "aws_eks_node_group" "services" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  subnet_ids      = var.subnet_ids
  node_role_arn   = aws_iam_role.eks-nodes.arn

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  ami_type        = var.gpu ? "AL2_x86_64_GPU" : "AL2_x86_64"
  release_version = var.release_version
  version         = var.k8s_version
  disk_size       = var.disk_size
  instance_types  = [var.instance_type]
  labels = {
    "node.kubernetes.io/instance-type" = var.instance_type
    "node.kubernetes.io/node-group"    = var.node_group_name
    "node.kubernetes.io/gpu"           = var.gpu
  }
  tags = merge(var.tags, {
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  })

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = var.source_security_group_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks-nodes" {
  name               = "eks-nodes"
  path               = "/${var.cluster_name}/"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

data aws_iam_policy_document "assume-role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data aws_iam_policy_document "cluster-autoscaler" {
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }
}

resource aws_iam_policy "cluster-autoscaler" {
  name   = "cluster-autoscaler"
  path   = "/${var.cluster_name}/"
  policy = data.aws_iam_policy_document.cluster-autoscaler.json
}

resource "aws_iam_role_policy_attachment" "eks-nodes-cluster-autoscaler" {
  policy_arn = aws_iam_policy.cluster-autoscaler.arn
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes.name
}
