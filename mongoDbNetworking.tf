data "mongodbatlas_network_container" "redstone_gateway_mongodbatlas_network_container" {
  project_id          = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  container_id        = mongodbatlas_advanced_cluster.redstone_gateway_mongodbatlas_cluster.replication_specs[0].container_id["AWS:EU_CENTRAL_1"]
}

resource "mongodbatlas_network_peering" "redstone_gateway_mongodbatlas_network_peering" {
  accepter_region_name   = "eu-central-1"
  project_id             = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  container_id           = mongodbatlas_advanced_cluster.redstone_gateway_mongodbatlas_cluster.replication_specs[0].container_id["AWS:EU_CENTRAL_1"]
  provider_name          = "AWS"
  route_table_cidr_block = local.vpc_cidr
  vpc_id                 = aws_vpc.redstone_gateway_vpc.id
  aws_account_id         = data.aws_caller_identity.aws_current_identity.account_id
}

resource "aws_vpc_peering_connection_accepter" "redstone_gateway_mongodbatlas_network_peering_accepter" {
  vpc_peering_connection_id = mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering.connection_id
  auto_accept = true
}

resource "mongodbatlas_project_ip_access_list" "redstone_gateway_mongodbatlas_project_ip_access_list" {
  project_id         = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
//  TODO: move to private sg
  aws_security_group = aws_security_group.redstone_gateway_security_groups["public"].id

  depends_on = [mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering]
}

resource "aws_route" "redstone_gateway_mongodbatlas_peering_connection_route" {
  route_table_id            = aws_route_table.redstone_gateway_public_rt.id
  destination_cidr_block    = data.mongodbatlas_network_container.redstone_gateway_mongodbatlas_network_container.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.redstone_gateway_mongodbatlas_network_peering.connection_id
}