resource "aws_lb" "redstone_gateway_loadbalancer" {
  name            = "redstone-gateway-lb"
  subnets         = aws_subnet.redstone_gateway_public_subnets.*.id
  security_groups = [aws_security_group.redstone_gateway_lb_security_group.id]
}

resource "aws_lb_target_group" "redstone_gateway_loadbalancer_target_group" {
  name        = "redstone-gateway-lb-tg"
  port        = local.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.redstone_gateway_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    path                = "/"
    protocol            = "HTTP"
    timeout             = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "redstone_gateway_loadbalancer_listener" {
  load_balancer_arn = aws_lb.redstone_gateway_loadbalancer.arn
  port              = local.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redstone_gateway_loadbalancer_target_group.arn
  }
}
