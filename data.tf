data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ami_image" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
