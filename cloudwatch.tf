resource "aws_cloudwatch_log_group" "redstone_gateway_ecs_log_group" {
  name              = "${local.name_prefix}_log_group"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "redstone_gateway_ecs_cluster_log_group" {
  name              = "${local.name_prefix}_cluster_log_group"
  retention_in_days = 90
}