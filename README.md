# terraform-aws-eks

This terraform module helps to create and provision

- a VPC with public and private subnets with pre-configured network ACLs
- a private EKS control plane
- any number of managed node groups
- a default IAM policy for ALB ingress controller
- any number of IAM for EKS service account
