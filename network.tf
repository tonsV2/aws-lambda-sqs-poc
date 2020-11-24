data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "private" {
  count = length(var.cidr_block_subnets_private)
  cidr_block = var.cidr_block_subnets_private[count.index]
  vpc_id = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_security_group" "lambda" {
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "PostgreSQL"
    from_port = 5432
    protocol = "tcp"
    to_port = 5432
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
