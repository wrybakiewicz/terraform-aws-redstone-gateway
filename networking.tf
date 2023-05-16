locals {
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidrs = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  public_subnet_count = 3
}

data "aws_availability_zones" "availability_zones" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.availability_zones.names
  result_count = local.public_subnet_count
}

resource "aws_vpc" "redstone_gateway_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}_vpc"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "redstone_gateway_public_subnets" {
  count                   = local.public_subnet_count
  cidr_block              = local.public_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.redstone_gateway_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${local.name_prefix}_public_sn_${count.index}"
  }
}

resource "aws_security_group" "redstone_gateway_lb_security_group" {
  name        = "lb_sg"
  description = "Security group for Load Balancer."
  vpc_id      = aws_vpc.redstone_gateway_vpc.id
  ingress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redstone_gateway_ecs_security_group" {
  name        = "ecs_sg"
  description = "Security group for ECS."
  vpc_id      = aws_vpc.redstone_gateway_vpc.id
  ingress {
    from_port       = local.app_port
    to_port         = local.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.redstone_gateway_lb_security_group.id]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "redstone_gateway_public_rt" {
  vpc_id = aws_vpc.redstone_gateway_vpc.id

  tags = {
    Name = "${local.name_prefix}_public_rt"
  }
}

resource "aws_internet_gateway" "redstone_gateway_internet_gateway" {
  vpc_id = aws_vpc.redstone_gateway_vpc.id

  tags = {
    Name = "${local.name_prefix}_igw"
  }
}

resource "aws_route" "redstone_gateway_public_internet_gateway_route" {
  route_table_id         = aws_route_table.redstone_gateway_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redstone_gateway_internet_gateway.id
}

resource "aws_route_table_association" "redstone_gateway_public_assoc" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.redstone_gateway_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.redstone_gateway_public_rt.id
}