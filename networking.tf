locals {
  vpc_cidr = "10.2.0.0/16"
  public_subnet_cidr = "10.2.1.0/24"
  private_subnet_cidr = "10.2.2.0/24"
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Security group for public access."
      ingress = {
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    private = {
      name        = "private_sg"
      description = "Security group for private access."
      ingress = {
        https = {
          from        = 27017
          to          = 27017
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}

data "aws_availability_zones" "availability_zones" {}

resource "random_integer" "random_az_index" {
  min = 0
  max = length(data.aws_availability_zones.availability_zones.names) - 1
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

resource "aws_subnet" "redstone_gateway_public_subnet" {
  cidr_block              = local.public_subnet_cidr
  vpc_id                  = aws_vpc.redstone_gateway_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.availability_zones.names[random_integer.random_az_index.id]

  tags = {
    Name = "${local.name_prefix}_public"
  }
}

resource "aws_subnet" "redstone_gateway_private_subnet" {
  cidr_block              = local.private_subnet_cidr
  vpc_id                  = aws_vpc.redstone_gateway_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.availability_zones.names[random_integer.random_az_index.id]

  tags = {
    Name = "${local.name_prefix}_private"
  }
}

resource "aws_security_group" "redstone_gateway_security_groups" {
  for_each    = local.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.redstone_gateway_vpc.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
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

resource "aws_default_route_table" "redstone_gateway_private_rt" {
  default_route_table_id = aws_vpc.redstone_gateway_vpc.default_route_table_id

  tags = {
    Name = "${local.name_prefix}_private_rt"
  }
}

resource "aws_internet_gateway" "redstone_gateway_internet_gateway" {
  vpc_id = aws_vpc.redstone_gateway_vpc.id

  tags = {
    Name = "${local.name_prefix}_igw"
  }
}

resource "aws_route" "redstone_gateway_public_default_route" {
  route_table_id         = aws_route_table.redstone_gateway_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redstone_gateway_internet_gateway.id
}

resource "aws_route_table_association" "redstone_gateway_public_assoc" {
  subnet_id      = aws_subnet.redstone_gateway_public_subnet.id
  route_table_id = aws_route_table.redstone_gateway_public_rt.id
}