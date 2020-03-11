locals {
  num_subnets  = length(var.subnets_az_to_cidr)
  subnet_azs   = keys(var.subnets_az_to_cidr)
  subnet_cidrs = values(var.subnets_az_to_cidr)
}

data "aws_vpc" "eks" {
  id = var.vpc_id
}

resource "aws_subnet" "eks" {
  count = local.num_subnets

  vpc_id                          = var.vpc_id
  cidr_block                      = local.subnet_cidrs[count.index]
  availability_zone               = local.subnet_azs[count.index]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-${local.subnet_azs[count.index]}-private"
    Role                                        = "private"
    AZ                                          = local.subnet_azs[count.index]
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_network_acl" "private" {
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.eks[*].id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private"
    Role = "private"
  })
}

resource "aws_network_acl_rule" "http-ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = data.aws_vpc.eks.cidr_block
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "https-ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 110
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = data.aws_vpc.eks.cidr_block
  from_port   = 443
  to_port     = 443
}

resource "aws_network_acl_rule" "ssh-ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 120
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = data.aws_vpc.eks.cidr_block
  from_port   = 22
  to_port     = 22
}

resource "aws_network_acl_rule" "return-traffic-ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 140
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 1024
  to_port     = 65535
}

resource "aws_network_acl_rule" "http-egress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "https-egress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 110
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
}

resource "aws_route_table" "private" {
  count  = local.num_subnets
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${local.subnet_azs[count.index]}-private"
    AZ   = aws_subnet.eks[count.index].availability_zone
  })
}

resource "aws_route_table_association" "private" {
  count          = local.num_subnets
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.private[count.index].id
  depends_on     = [aws_subnet.eks, aws_route_table.private]
}

resource "aws_route" "nat" {
  count                  = local.num_subnets
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = var.azs_to_nat_ids[local.subnet_azs[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
}
