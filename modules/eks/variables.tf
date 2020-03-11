variable "cluster_name" {
  type        = string
  description = "Name for the EKS cluster."
}
variable "vpc_id" {
  type = string
}
variable "subnets_az_to_cidr" {
  type        = map(string)
  description = "Mapping of availability zone to private subnet CIDR blocks to be created and used for EKS."
}

variable "azs_to_nat_ids" {
  type        = map(string)
  description = "Mapping of availability zone to NAT gateway ids."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to all the resources created by this module."
}
variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane."
}
variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit"]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging."
}
variable "k8s_version" {
  type        = string
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS."
}
