output "endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "Endpoint to access EKS control plane APIs."
}
output "kubeconfig-certificate-authority-data" {
  value       = aws_eks_cluster.eks.certificate_authority.0.data
  description = "Cluster CA to access EKS control plane APIs."
}
output "subnet_ids" {
  value       = aws_subnet.eks[*].id
  description = "List of private subnet ids."
}
output "network_acl_ids" {
  value       = aws_network_acl.private[*].id
  description = "List of network acl ids for the corresponding private subnets."
}
