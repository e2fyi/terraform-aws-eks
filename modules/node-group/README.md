# node-group

This terraform module help creates a managed node group for EKS.

```bash
module "node-group-services" {
    source = "./modules/node-group"

    cluster_name = "eks-sg-dev"
    node_group_name = "services"
    subnet_ids = []

    k8s_version = "1.15"
    release_version = "ami-08805da128ddc2ee1"  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html

    instance_type = "t3.medium"
    gpu = false
    disk_size = 20
    ec2_ssh_key = "<some_key_name>"
    source_security_group_ids = []

    desired_size = 1
    min_size = 1
    max_size = 5

    tags = {}
}
```
