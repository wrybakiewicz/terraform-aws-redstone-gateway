resource "aws_lb" "redstone_gateway_loadbalancer" {
  name            = "redstone-gateway-lb"
  subnets         = aws_subnet.redstone_gateway_public_subnets.*.id
  security_groups = [aws_security_group.redstone_gateway_security_groups["public"].id]
}

resource "aws_lb_target_group" "redstone_gateway_loadbalancer_target_group" {
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.redstone_gateway_vpc.id
  //TODO: add healthcheck
}

resource "aws_lb_listener" "redstone_gateway_loadbalancer_listener" {
  load_balancer_arn = aws_lb.redstone_gateway_loadbalancer.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redstone_gateway_loadbalancer_target_group.arn
  }
}
