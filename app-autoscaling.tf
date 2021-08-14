resource "aws_appautoscaling_target" "ecs-service" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs-service" {
  name               = "ecs-service-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs-service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

