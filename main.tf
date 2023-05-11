locals {
  ecs_cluster_name = "redstone_gateway"
}

resource "aws_ecs_cluster" "redstone_gateway_ecs_cluster" {
  name = local.ecs_cluster_name
}