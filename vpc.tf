# Attach an IAM role to EC2 instance with EC2fullaccess

# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = "${var.vpc-cidr}"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "VPC"
  }
}

# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "IGW"
  }
}

# terraform aws create public subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet-1-cidr}"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet 1"
  }
}

# terraform aws create public subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet-2-cidr}"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet 2"
  }
}

# terraform aws create route table with IGW
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

# Associate "Route Table" to Public Subnet 1
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-1.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Associate "Route Table" to Public Subnet 2
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-2.id
  route_table_id      = aws_route_table.public-route-table.id
}

# terraform aws create private subnet 1
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private-subnet-1-cidr}"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags      = {
    Name    = "Private Subnet 1"
  }
}

# terraform aws create private subnet 2
resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private-subnet-2-cidr}"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags      = {
    Name    = "Private Subnet 2"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.internet-gateway.id]
  tags = {
    Name = "NAT Gateway EIP"
  }
}

# NAT Gateway for VPC
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public-subnet-1.id

  tags = {
    Name = "NAT Gateway"
  }
}

# Route table for Private subnets
resource "aws_route_table" "private-route-table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags       = {
    Name     = "Private Route Table"
  }
}

# Associate Route table to Private subnet 1
resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.private-subnet-1.id
  route_table_id      = aws_route_table.private-route-table.id
}

# Associate Route table to Private subnet 2
resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.private-subnet-2.id
  route_table_id      = aws_route_table.private-route-table.id
}