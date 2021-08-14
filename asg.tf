resource "aws_launch_configuration" "container-instance" {
  name_prefix          = "${var.project}-${var.environment}"
  image_id             = data.aws_ssm_parameter.ami_image.value
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

  key_name                    = aws_key_pair.ec2.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/ecs-init.sh")

  security_groups = [
    aws_security_group.ec2.id
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "containers" {
  name_prefix      = "${var.project}-${var.environment}"
  max_size         = 4
  min_size         = 1
  default_cooldown = 60

  vpc_zone_identifier  = aws_subnet.public.*.id
  launch_configuration = aws_launch_configuration.container-instance.name
  health_check_type    = "ELB"
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  tag {
    key                 = "Name"
    value               = "${var.project}-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role" "ec2" {
  name = "${var.project}-${var.environment}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2-role" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ec2.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "${var.project}-${var.environment}"
  role = aws_iam_role.ec2.id
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2-ssh-key"
  public_key = file("${path.module}/instance.key.pub")
}
