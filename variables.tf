variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region. Defaults to Singapore."
}
variable "eks_control_plane" {
  type        = bool
  default     = true
  description = "Set to false to NOT create a EKS control plane."
}
variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC to host EKS."
}
variable "cluster_name" {
  type        = string
  description = "Name of the eks cluster."
}
variable "public_subnets" {
  type = map(string)
  default = {
    ap-southeast-1a = "10.0.250.0/24"
    ap-southeast-1b = "10.0.251.0/24"
    ap-southeast-1c = "10.0.252.0/24"
  }
  description = "Mapping of availability zone to CIDR blocks for public subnets."
}
variable "private_eks_subnets" {
  type = map(string)
  default = {
    ap-southeast-1a = "10.0.0.0/18"
    ap-southeast-1b = "10.0.64.0/18"
    ap-southeast-1c = "10.0.128.0/18"
  }
  description = "Mapping of availability zone to CIDR blocks for private subnets for EKS."
}
variable "whitelisted_cidr_block" {
  type        = string
  default     = ""
  description = "CIDR block to whitelist for public subnet network ACL to allow SSH access. Defaults to None."
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to all the resources created by this module."
}
