resource "aws_ecs_cluster" "cluster" {
  name               = "cluster-demo"
  capacity_providers = [aws_ecs_capacity_provider.ec2.name]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "task-ec2"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = 1024
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution.arn

  container_definitions = jsonencode([
    {
      name      = "node"
      image     = "registry.hub.docker.com/wyfy/express-server:1.0"
      cpu       = 1024
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
    },
  ])
}

resource "aws_ecs_service" "service" {
  name                 = "ecs-service"
  cluster              = aws_ecs_cluster.cluster.arn
  launch_type          = "EC2"
  desired_count        = 2
  scheduling_strategy  = "REPLICA"
  task_definition      = aws_ecs_task_definition.task.arn
  force_new_deployment = true

  # starts 2 new tasks before stoping the old 2 tasks
  deployment_maximum_percent = "200"
  # may stop 1 task before starting new task
  deployment_minimum_healthy_percent = "50"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "node"
    target_group_arn = aws_lb_target_group.this.arn
    container_port   = "5000"
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "capacity-provider-${aws_autoscaling_group.containers.name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.containers.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      instance_warmup_period    = 120
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
