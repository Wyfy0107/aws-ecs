resource "aws_security_group" "alb" {
  name   = "alb-sgs"
  vpc_id = aws_vpc.ecs.id

  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }
}

resource "aws_security_group" "task" {
  name   = "ecs-task"
  vpc_id = aws_vpc.ecs.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }
}

resource "aws_security_group" "ec2" {
  name   = "ec2"
  vpc_id = aws_vpc.ecs.id

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }
}
