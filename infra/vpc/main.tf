resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name : "tasl-vpc" }
}
resource "aws_subnet" "public_subnets" {
  count                   = length(var.cidr_public_subnet)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.cidr_public_subnet, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name : "task-public-subnet" }
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name : "task-internet-gateway" }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = { Name : "task-route-table" }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.cidr_public_subnet)
  depends_on     = [aws_subnet.public_subnets, aws_route_table.route_table]
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.route_table.id
}
resource "aws_security_group" "security_group" {
  ingress {
    description = "allow all inbound rules"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound rules"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  name       = "task-security-group"
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]
  tags = {
    Name = "task-security-group"
  }
}
