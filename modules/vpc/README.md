# vpc

This terraform module creates a VPC and a set of public subnets.

**Quick start**

```bash
module "vpc-eks-sg-dev" {
    vpc_name = "eks-sg-dev"
    cluster_name = "eks-sg-dev"
    cidr_block = "10.0.0.0/16"
    subnets_az_to_cidr = {
        ap-southeast-1a = "10.0.250.0/24"
        ap-southeast-1b = "10.0.251.0/24"
        ap-southeast-1c = "10.0.252.0/24"
    }
    enable_dns_hostnames = true # required to resolve EKS endpoint
    cidr_block_for_ssh = "0.0.0.0/0"  # any IP can ssh into the public subnet

    tags = {}
}
```

## Details

This module creates and provisions:

- 1 VPC with the provided CIDR block
- 1 or more public subnets with a pre-configured network ACL
- 1 Route table for each public subnet
- 1 Internet Gateway with all the public route tables updated
- 1 Network ACL for each public subnet with the following permissions:
  - http/https to and from internet
  - ssh from a provided CIDR block
  - ssh to other subnets in the VPC
  - response traffics to/from within the subnets in the VPC
- If `cluster_name` is provided, the public subnets will be properly tagged so that it can be discovered by eks
