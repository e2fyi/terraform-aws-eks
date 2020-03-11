
variable "cluster_name" {
  type        = string
  description = "Name for the EKS cluster."
}
variable "node_group_name" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to all the resources created by this module."
}
variable "gpu" {
  type        = bool
  default     = false
  description = "Set true if the node group uses nodes with GPUs."
}
variable "disk_size" {
  type        = number
  default     = 20
  description = "Disk size in GiB for worker nodes. Defaults to 20."
}
variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type associated with the EKS Node Group. Defaults to t3.medium."
}
variable "release_version" {
  type        = string
  default     = ""
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version."
}
variable "k8s_version" {
  type        = string
  default     = ""
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided."
}
variable "ec2_ssh_key" {
  type        = string
  default     = ""
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group. If you specify this configuration, but do not specify source_security_group_ids when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0)."
}
variable "source_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify ec2_ssh_key, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0)."
}
variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes."
}
variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes."
}
variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes."
}
