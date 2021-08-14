resource "aws_lb" "ecs" {
  name_prefix        = "ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {
  name                 = "ecs-alb"
  protocol             = "HTTP"
  port                 = 5000
  target_type          = "instance"
  vpc_id               = aws_vpc.ecs.id
  deregistration_delay = 60

  health_check {
    enabled             = true
    unhealthy_threshold = 6
    port                = "traffic-port"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
