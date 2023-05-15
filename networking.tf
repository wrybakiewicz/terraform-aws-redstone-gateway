locals {
  vpc_cidr = "10.2.0.0/16"
  public_subnet_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnet_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  public_subnet_count = 2
  private_subnet_count = 2
  max_subnets = 2
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
        http = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        app = {
          from        = 3000
          to          = 3000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        allTest = {
          from = 0
          to = 0
          protocol = "-1"
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

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.availability_zones.names
  result_count = local.max_subnets
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
  count = local.public_subnet_count
  cidr_block              = local.public_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.redstone_gateway_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${local.name_prefix}_public_sn_${count.index}"
  }
}

resource "aws_subnet" "redstone_gateway_private_subnets" {
  count                   = local.private_subnet_count
  cidr_block              = local.private_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.redstone_gateway_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${local.name_prefix}_private_sn_${count.index}"
  }
}


//TODO: delete ?
resource "aws_db_subnet_group" "redstone_gateway_db_sng" {
  name       = "${local.name_prefix}_db_sng"
  //TODO:
  subnet_ids = aws_subnet.redstone_gateway_public_subnets.*.id
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