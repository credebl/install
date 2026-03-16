# Get all availability zones in the region
data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available_zones.names[
    count.index % length(data.aws_availability_zones.available_zones.names)
  ]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet_app" {
  count = length(var.private_app_subnet_cidr)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_app_subnet_cidr[count.index]

  availability_zone = data.aws_availability_zones.available_zones.names[
    count.index % length(data.aws_availability_zones.available_zones.names)
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet_db" {
  count = length(var.private_db_subnet_cidr)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_db_subnet_cidr[count.index]

  availability_zone = data.aws_availability_zones.available_zones.names[
    count.index % length(data.aws_availability_zones.available_zones.names)
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-db-subnet-${count.index + 1}"
  }
}

# Create Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "internet_gateway" {
vpc_id = aws_vpc.vpc.id

tags = {
    Name = "${var.project_name}-${var.environment}-igw"
}
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public_rt"
  }
}

# Associate Public Subnets to Public Route Table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table for app
resource "aws_route_table" "private_app_route_table" {
  count = var.private_route_table_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-rt"
  }
}

# Associate Private app Subnets with Private Route Tables
resource "aws_route_table_association" "private_app_subnet_route_table_association" {
  count          = length(var.private_app_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet_app[count.index].id
  route_table_id = aws_route_table.private_app_route_table[count.index].id
}

# Create Private Route Table for db
resource "aws_route_table" "private_db_route_table" {
  count = var.private_route_table_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-db-rt"
  }
}

# Associate Private db Subnets with Private Route Tables
resource "aws_route_table_association" "private_db_subnet_route_table_association" {
  count          = length(var.private_db_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet_db[count.index].id
  route_table_id = aws_route_table.private_db_route_table[count.index].id
}


# Create NAT Gateway in each public subnet
# Allocate elastic IP for the NAT gateway in AZ1
resource "aws_eip" "nat_eip" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-${count.index + 1}"
  }
}

# Create NAT gateways in the public subnets (AZ1 and AZ2)
resource "aws_nat_gateway" "nat_gateway" {
  count = var.nat_gateway_count

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Add route to NAT gateway for private app route table
resource "aws_route" "private_app_nat_route" {
  count                  = var.private_route_table_count
  route_table_id         = aws_route_table.private_app_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}