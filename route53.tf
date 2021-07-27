resource "aws_route53_record" "ecs" {
  zone_id = var.hosted_zone_id
  name    = "ecs.mlem-mlem.net"
  type    = "A"

  alias {
    name                   = aws_lb.ecs.dns_name
    zone_id                = aws_lb.ecs.zone_id
    evaluate_target_health = true
  }
}
