locals {
  name         = var.cluster_name == "" ? var.vpc_name : var.cluster_name
  num_subnets  = length(var.subnets_az_to_cidr)
  subnet_azs   = keys(var.subnets_az_to_cidr)
  subnet_cidrs = values(var.subnets_az_to_cidr)
  nat_azs      = keys(var.subnets_az_with_nat)
  num_nat      = length(var.subnets_az_with_nat)
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({ Name = var.vpc_name }, var.tags)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count = local.num_subnets

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = local.subnet_cidrs[count.index]
  availability_zone               = local.subnet_azs[count.index]
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

  tags = merge(var.tags, {
    Name = "${local.name}-${local.subnet_azs[count.index]}-public"
    Role = "public"
    AZ   = local.subnet_azs[count.index]
    }, var.cluster_name == "" ? {} : {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_network_acl" "public" {

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  tags = merge(var.tags, {
    Name = "${local.name}-public"
    Role = "public"
  })
}

resource "aws_network_acl_rule" "http-ingress-internet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "https-ingress-internet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 110
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
}

resource "aws_network_acl_rule" "ssh-ingress-whitelist" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 120
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = var.cidr_block_for_ssh
  from_port   = 22
  to_port     = 22
}

resource "aws_network_acl_rule" "response-ingress-internet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 140
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 1024
  to_port     = 65535
}

resource "aws_network_acl_rule" "http-egress-internet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "https-egress-internet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 110
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
}

resource "aws_network_acl_rule" "response-egress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 140
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 32768
  to_port     = 65535
}

resource "aws_network_acl_rule" "ssh-egress-to-private-subnet" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 150
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = var.cidr_block
  from_port   = 22
  to_port     = 22
}

resource "aws_route_table" "public" {
  count  = local.num_subnets
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${local.name}-${local.subnet_azs[count.index]}-public"
    Role = "public"
    AZ   = aws_subnet.public[count.index].availability_zone
  })
}

resource "aws_route_table_association" "public" {
  count          = local.num_subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
  depends_on     = [aws_subnet.public, aws_route_table.public]
}

resource "aws_route" "igw" {
  count                  = local.num_subnets
  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public]
}

resource "aws_eip" "nat" {
  count = local.num_nat
  vpc   = true
}

resource "aws_nat_gateway" "main" {
  count         = local.num_nat
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[index(local.subnet_azs, local.nat_azs[count.index])].id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-${local.nat_azs[count.index]}"
    Role = "nat"
    AZ   = local.subnet_azs[count.index]
  })
}
