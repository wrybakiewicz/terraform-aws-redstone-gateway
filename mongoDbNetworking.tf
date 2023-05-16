locals {
  container_id_key = "${local.provider_name}:${var.mongodbatlas_region}"
  container_id     = mongodbatlas_advanced_cluster.redstone_gateway_mongodbatlas_cluster.replication_specs[0].container_id[local.container_id_key]
}

data "mongodbatlas_network_container" "redstone_gateway_mongodbatlas_network_container" {
  project_id   = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  container_id = local.container_id
}

resource "mongodbatlas_network_peering" "redstone_gateway_mongodbatlas_network_peering" {
  accepter_region_name   = data.aws_region.aws_current_region.name
  project_id             = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  container_id           = local.container_id
  provider_name          = local.provider_name
  route_table_cidr_block = local.vpc_cidr
  vpc_id                 = aws_vpc.redstone_gateway_vpc.id
  aws_account_id         = data.aws_caller_identity.aws_current_identity.account_id
}

resource "aws_vpc_peering_connection_accepter" "redstone_gateway_mongodbatlas_network_peering_accepter" {
  vpc_peering_connection_id = mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering.connection_id
  auto_accept               = true
}

resource "mongodbatlas_project_ip_access_list" "redstone_gateway_mongodbatlas_project_ip_access_list" {
  project_id         = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  aws_security_group = aws_security_group.redstone_gateway_ecs_security_group.id
  depends_on         = [mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering]
}

resource "aws_route" "redstone_gateway_mongodbatlas_peering_connection_route" {
  route_table_id            = aws_route_table.redstone_gateway_public_rt.id
  destination_cidr_block    = data.mongodbatlas_network_container.redstone_gateway_mongodbatlas_network_container.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering.connection_id
}