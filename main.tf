locals {
  ecr_image          = "public.ecr.aws/y7v2w8b2/redstone-cache-service:f209220"
  ecs_container_name = "${local.name_prefix}_container"
  ecs_task_cpu       = 1024
  ecs_task_memory    = 2048
}

data "aws_region" "aws_current_region" {}

resource "aws_ecs_cluster" "redstone_gateway_ecs_cluster" {
  name = "${local.name_prefix}_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "redstone_gateway_ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.redstone_gateway_ecs_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "redstone_gateway_ecs_service" {
  name            = "${local.name_prefix}_service"
  cluster         = aws_ecs_cluster.redstone_gateway_ecs_cluster.id
  task_definition = aws_ecs_task_definition.redstone_gateway_ecs_task_definition.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.redstone_gateway_loadbalancer_target_group.arn
    container_name   = local.ecs_container_name
    container_port   = local.app_port
  }

  network_configuration {
    subnets          = aws_subnet.redstone_gateway_public_subnets.*.id
    security_groups  = [aws_security_group.redstone_gateway_ecs_security_group.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "redstone_gateway_ecs_task_definition" {
  family                   = "${local.name_prefix}_task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_task_cpu
  memory                   = local.ecs_task_memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.redstone_gateway_ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = local.ecs_container_name
      image     = local.ecr_image
      cpu       = local.ecs_task_cpu
      memory    = local.ecs_task_memory
      essential = true
      portMappings : [
        {
          "containerPort" : local.app_port,
          "hostPort" : local.app_port
        }
      ]
      environment = [
        { name : "ENABLE_STREAMR_LISTENING", value : "true" },
        { name : "ENABLE_DIRECT_POSTING_ROUTES", value : "false" }
      ]
      secrets = [
        { name : "MONGO_DB_URL", valueFrom : aws_ssm_parameter.ssm_param_connection_string.arn },
        { name : "API_KEY_FOR_ACCESS_TO_ADMIN_ROUTES", valueFrom : aws_ssm_parameter.ssm_param_api_key_for_access_to_admin_routes.arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group  = aws_cloudwatch_log_group.redstone_gateway_ecs_log_group.name
          awslogs-region = data.aws_region.aws_current_region.name
          awslogs-stream-prefix : "redstone"
        }
      }
    }
  ])
}