resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  # use only one most recent data to evaluate
  evaluation_periods = 1
  # check every 1 minute
  period      = 60
  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"
  threshold   = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.cluster.arn
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]

  tags = {
    Name = "ecs-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "ecs-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    ClusterName = aws_ecs_cluster.cluster.arn
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]


  tags = {
    Name = "ecs-cpu-low"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/fargate/service/ecs-app-dev"
  retention_in_days = 1

  tags = {
    Name = "ecs_logs"
  }
}
