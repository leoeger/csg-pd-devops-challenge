# terraform/modules/networking/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "vpc-${var.env}", name = "csgtest" }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "subnet-public-${var.env}-${count.index}", name = "csgtest" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "subnet-private-${var.env}-${count.index}", name = "csgtest" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "igw-${var.env}", name = "csgtest" }
}

resource "aws_security_group" "alb" {
  name   = "secgrp-alb-${var.env}"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "secgrp-alb-${var.env}", name = "csgtest" }
}

resource "aws_security_group" "ecs" {
  name   = "secgrp-ecs-${var.env}"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "secgrp-ecs-${var.env}", name = "csgtest" }
}

resource "aws_security_group" "rds" {
  name   = "secgrp-rds-${var.env}"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  tags = { Name = "secgrp-rds-${var.env}", name = "csgtest" }
}

data "aws_availability_zones" "available" {}

output "vpc_id"              { value = aws_vpc.main.id }
output "public_subnet_ids"  { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "sg_alb_id"          { value = aws_security_group.alb.id }
output "sg_ecs_id"          { value = aws_security_group.ecs.id }
output "sg_rds_id"          { value = aws_security_group.rds.id }