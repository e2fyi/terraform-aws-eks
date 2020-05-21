provider "aws" {
  version = "~> 2.52"
  region  = var.aws_region
}

locals {
  tags = merge({
    Cluster = var.cluster_name
    Region  = var.aws_region
  }, var.tags)
}

module "vpc-eks-sg-dev" {
  source = "./modules/vpc"

  vpc_name           = var.cluster_name
  cluster_name       = var.cluster_name
  cidr_block         = var.vpc_cidr_block
  subnets_az_to_cidr = var.public_subnets
  subnets_az_with_nat = {
    for az, _ in var.private_eks_subnets : az => true || var.eks_control_plane
  }
  enable_dns_hostnames = true                       # required to resolve EKS endpoint
  cidr_block_for_ssh   = var.whitelisted_cidr_block # any IP can ssh into the public subnet

  tags = local.tags
}

module "s3-logs" {
  source = "./modules/s3"

  bucket        = "${var.cluster_name}-logs"
  acl           = "log-delivery-write"
  versioning    = false
  sse_algorithm = "AES256"

  folder_to_expiration_days = {
    log = 30
  }
  tags = local.tags
}

module "s3-kubeflow" {
  source = "./modules/s3"

  bucket        = "${var.cluster_name}-kubeflow"
  versioning    = false
  sse_algorithm = "AES256"

  folder_to_expiration_days = {
    tmp = 7
  }
  logging = {
    "${module.s3-logs.id}" = "log/s3/${var.cluster_name}-kubeflow"
  }

  whitelisted_ips = {
    kubeflow = [var.vpc_cidr_block]
  }

  tags = local.tags
}


module "eks-sg-dev" {

  source = "./modules/eks"

  enabled      = var.eks_control_plane
  cluster_name = "eks-sg-dev"
  k8s_version  = "1.15"

  vpc_id             = module.vpc-eks-sg-dev.vpc_id
  subnets_az_to_cidr = var.private_eks_subnets
  azs_to_nat_ids     = module.vpc-eks-sg-dev.azs_to_nat_ids

  enabled_cluster_log_types = ["api", "audit"]
  tags                      = local.tags
}
