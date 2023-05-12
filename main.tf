resource "aws_ecs_cluster" "redstone_gateway_ecs_cluster" {
  name = "${local.name_prefix}_cluster"

  configuration {
    execute_command_configuration {
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.redstone_gateway_ecs_cluster_log_group.name
      }
      logging = "OVERRIDE"
    }
  }
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

  capacity_provider_strategy {
    base = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

//  load_balancer {
//    target_group_arn = aws_lb_target_group.foo.arn
//    container_name   = "mongo"
//    container_port   = 8080
//  }

  network_configuration {
    subnets = [aws_subnet.redstone_gateway_public_subnet.id]
    security_groups = [aws_security_group.redstone_gateway_security_groups["public"].id]
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
  cpu                      = 4096
  memory                   = 8192
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.redstone_gateway_ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name   = "${local.name_prefix}_container"
      image  = "public.ecr.aws/y7v2w8b2/redstone-cache-service:6303414"
      cpu    = 4096
      memory = 8192
      essential = true
      portMappings: [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ]
      environment = [
        {"name": "ENABLE_STREAMR_LISTENING", "value": "true"},
        {"name": "ENABLE_DIRECT_POSTING_ROUTES",   "value": "false" },
        {"name": "API_KEY_FOR_ACCESS_TO_ADMIN_ROUTES",   "value": var.admin_routes_api_key }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
//          awslogs-create-group: "true"
          awslogs-group  = "${local.name_prefix}_log_group"
          awslogs-region = local.aws_region
          awslogs-stream-prefix: "redstone"
        }
      }
    }
  ])
}