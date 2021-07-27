resource "aws_ecs_cluster" "cluster" {
  name               = "cluster-demo"
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "task-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_role.arn
  task_role_arn            = aws_iam_role.task_logs_role.arn

  container_definitions = jsonencode([
    {
      name      = "node"
      image     = "registry.hub.docker.com/wyfy/express-server:1.0"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      "logConfiguration" = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/fargate/service/ecs-app-dev",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
}

resource "aws_ecs_service" "service" {
  name                 = "ecs-service"
  cluster              = aws_ecs_cluster.cluster.arn
  launch_type          = "FARGATE"
  desired_count        = 2
  scheduling_strategy  = "REPLICA"
  task_definition      = aws_ecs_task_definition.task.arn
  force_new_deployment = true

  ## starts 2 new tasks before stoping the old 2 tasks
  deployment_maximum_percent = "200"
  ## may stop 1 task before starting new task
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

  network_configuration {
    subnets          = aws_subnet.public.*.id
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }

}
