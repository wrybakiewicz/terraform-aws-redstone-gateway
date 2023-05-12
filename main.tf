resource "aws_ecs_cluster" "redstone_gateway_ecs_cluster" {
  name = "${local.name_prefix}_cluster"
}