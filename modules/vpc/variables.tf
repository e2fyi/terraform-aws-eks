variable "vpc_name" {
  type        = string
  description = "Name for the VPC"
}
variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}
variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC"
}
variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}
variable "enable_dns_hostnames" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
}
variable "tags" {
  type = map(string)
  default = {
    module_repo = "https://github.com/e2fyi/terraform-modules"
  }
  description = "A mapping of tags to assign to all the resources created by this module."
}
variable "subnets_az_to_cidr" {
  type        = map(string)
  description = "A mapping of availabity zone to cidr blocks for the public subnets to be created."
}
variable "subnets_az_with_nat" {
  type        = map(bool)
  description = "A mapping of availability zones to be deployed with NAT gateway."
}
variable "cidr_block_for_ssh" {
  type    = string
  default = "0.0.0.0/0"
}
variable "cluster_name" {
  type        = string
  default     = ""
  description = "Name of the EKS cluster you want to deploy into this VPC."
}
