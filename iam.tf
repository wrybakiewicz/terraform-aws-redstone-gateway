data "aws_iam_policy_document" "redstone_gateway_ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "redstone_gateway_ecs_task_execution_role" {
  name                = "${local.name_prefix}_ecs_task_execution_role"
  assume_role_policy  = data.aws_iam_policy_document.redstone_gateway_ecs_assume_role_policy.json
  //TODO
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}