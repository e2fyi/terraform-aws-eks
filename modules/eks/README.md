# eks

This terraform modules creates an eks control plane and a set of private subnets inside an existing VPC. This module assumes the VPC has at least 1 public subnet with a provisioned and routed internet gateway.

**Quick start**

```hcl
module "eks" {
    source = "./modules/eks"

    cluster_name        = "eks-sg-dev"
    k8s_version         = "1.15"

    vpc_id              = <place_holder_vpc_id>
    subnets_az_to_cidr  = {
        ap-southeast-1a = "10.0.0.0/20"
        ap-southeast-1b = "10.0.16.0/20"
        ap-southeast-1c = "10.0.32.0/20"
    }

    enabled_cluster_log_types = ["api", "audit"]
    tags                      = {}
}
```

## Details

This module creates and provisions:

- 1 private access-only EKS control plane (i.e. k8s api is only accessible from within the VPC)
- 1 or more private subnets with pre-configured network ACL
- default private network ACL for each private subnet with the following permissions:
  - http, https, and ssh from subnets inside the same VPC (e.g. ssh from an ec2 in public subnet)
  - http and https requests to internet (no ssh from within private subnet to other networks)
  - traffic to and from the NAT gateway
- 1 NAT gateway for each subnet
- 1 Route table for each subnet with a routing rule for the NAT gateway

All subnets, NAT gateways, and route tables will have the following tags, and they can be used to retrieve references so that more routes, or network ACL rules can be attached to the route table or network ACL.

- Name = `<cluster_name>-<availability_zone>-private`
- AZ = `<availability-zone>`
- Role = `private`
