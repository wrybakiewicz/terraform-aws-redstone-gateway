locals {
  ecr_image = "public.ecr.aws/y7v2w8b2/redstone-cache-service:f209220"
}

data "aws_region" "aws_current_region" {}

resource "aws_ecs_cluster" "redstone_gateway_ecs_cluster" {
  name = "${local.name_prefix}_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "redstone_gateway_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.redstone_gateway_ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "redstone_gateway_ecs_service" {
  name            = "${local.name_prefix}_service"
  cluster         = aws_ecs_cluster.redstone_gateway_ecs_cluster.id
  task_definition = aws_ecs_task_definition.redstone_gateway_ecs_task_definition.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.redstone_gateway_loadbalancer_target_group.arn
    container_name   = "${local.name_prefix}_container"
    container_port   = local.app_port
  }

  network_configuration {
    subnets = aws_subnet.redstone_gateway_public_subnets.*.id
    security_groups = [aws_security_group.redstone_gateway_ecs_security_group.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy
    ]
  }
}

resource "aws_ecs_task_definition" "redstone_gateway_ecs_task_definition" {
  family = "${local.name_prefix}_task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.redstone_gateway_ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name   = "${local.name_prefix}_container"
      image  = local.ecr_image
      cpu    = 1024
      memory = 2048
      essential = true
      portMappings: [
        {
          "containerPort": local.app_port,
          "hostPort": local.app_port
        }
      ]
      environment = [
        {name: "ENABLE_STREAMR_LISTENING", value: "true"},
        {name: "ENABLE_DIRECT_POSTING_ROUTES",   value: "false" }
      ]
      secrets = [
        {name: "MONGO_DB_URL", valueFrom: aws_ssm_parameter.ssm_param_connection_string.arn},
        {name: "API_KEY_FOR_ACCESS_TO_ADMIN_ROUTES", valueFrom: aws_ssm_parameter.ssm_param_api_key_for_access_to_admin_routes.arn}
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group  = aws_cloudwatch_log_group.redstone_gateway_ecs_log_group.name
          awslogs-region = data.aws_region.aws_current_region.name
          awslogs-stream-prefix: "redstone"
        }
      }
    }
  ])
}