resource "aws_vpc" "ecs" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.ecs.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ecs-subnet"
  }
}

resource "aws_internet_gateway" "ecs" {
  vpc_id = aws_vpc.ecs.id

  tags = {
    Name = "ecs-internet-gatewway"
  }
}

resource "aws_route_table" "ecs" {
  vpc_id = aws_vpc.ecs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs.id
  }

  tags = {
    Name = "ecs-route-table"
  }
}

resource "aws_route_table_association" "demo" {
  count          = 2
  route_table_id = aws_route_table.ecs.id
  subnet_id      = aws_subnet.public[count.index].id
}
