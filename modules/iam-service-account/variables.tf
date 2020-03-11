variable "role_name" {
  type        = string
  description = "Name of the IAM role."
}
variable "cluster_name" {
  type        = string
  description = "Name of the eks cluster."
}
variable "policy" {
  type        = string
  description = "This is a JSON formatted string for the service account IAM role."
}
