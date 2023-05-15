data "aws_iam_policy_document" "redstone_gateway_ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "redstone_gateway_ecs_policy_document" {
  version = "2012-10-17"

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
    ]

    resources = ["*",]
  }
}

resource "aws_iam_policy" "redstone_gateway_ecs_policy" {
  name = "${local.name_prefix}_ecs_policy"
  policy = data.aws_iam_policy_document.redstone_gateway_ecs_policy_document.json
}

resource "aws_iam_role" "redstone_gateway_ecs_task_execution_role" {
  name                = "${local.name_prefix}_ecs_task_execution_role"
  assume_role_policy  = data.aws_iam_policy_document.redstone_gateway_ecs_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.redstone_gateway_ecs_policy.arn]
}