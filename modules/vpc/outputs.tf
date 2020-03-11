output "vpc_id" {
  value       = aws_vpc.main.id
  description = "Id of the VPC created in this module."
}
output "azs_to_nat_ids" {
  value       = zipmap(local.nat_azs, aws_nat_gateway.main[*].id)
  description = "Mapping of availability zone to NAT gateway id."
}
