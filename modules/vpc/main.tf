# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# use data source to get all avalablility zones in region
#data "aws_availability_zones" "available_zones" {}


# Configuration section for Public Subnet
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr)

  cidr_block        = element(var.public_subnet_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = merge(
    {
      "Name" = format(
        "${var.project_name}-${var.environment}-${var.public_subnet_interfix}-${count.index + 1}",
      )
    },
    var.additional_tags
  )
}


# Configuration section for Private Subnet for app
resource "aws_subnet" "private_subnet_app" {
  count = length(var.private_app_subnet_cidr)

  cidr_block        = element(var.private_app_subnet_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = merge(
    {
      "Name" = format(
        "${var.project_name}-${var.environment}-${var.private_app_subnet_interfix}-${count.index + 1}",
      )
    },
    var.additional_tags
  )
}


# Configuration section for Private Subnet for database
resource "aws_subnet" "private_subnet_db" {
  count = length(var.private_db_subnet_cidr)

  cidr_block        = element(var.private_db_subnet_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = merge(
    {
      "Name" = format(
        "${var.project_name}-${var.environment}-${var.private_db_subnet_interfix}-${count.index + 1}",
      )
    },
    var.additional_tags
  )
}


# create route table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.private_app_subnet_interfix}"
  }
}

# associate public subnet az1 to "public route table"
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}


