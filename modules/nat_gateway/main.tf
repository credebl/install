# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 
resource "aws_eip" "eip_for_nat_gateway_az1" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}_${var.environment}_eip1"
  }
}

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
resource "aws_eip" "eip_for_nat_gateway_az2" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}_${var.environment}_eip2"
  }
}

# create nat gateway in public subnet az1
resource "aws_nat_gateway" "nat_gateway" {
  count = var.nat_gateway_count

  allocation_id = element([aws_eip.eip_for_nat_gateway_az1.id, aws_eip.eip_for_nat_gateway_az2.id], count.index)

  subnet_id = element(var.public_subnet_ids, count.index)

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
  }


  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [var.internet_gateway_id]
}

# create private route 
resource "aws_route_table" "private_route_table" {
  count = length(var.private_route_table_names)

  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway[*].id, count.index)
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${element(var.private_route_table_names, count.index + 1)}"
  }
}

# associate private app subnet az1 with private route table az1
resource "aws_route_table_association" "private_app_route_table_association" {
  count          = length(var.private_app_subnet_ids)
  subnet_id      = element(var.private_app_subnet_ids, count.index)
  route_table_id = aws_route_table.private_route_table[0].id
}

# associate private app subnet az1 with private route table az1
resource "aws_route_table_association" "private_db_route_table_association" {
  count          = length(var.private_db_subnet_ids)
  subnet_id      = element(var.private_db_subnet_ids, count.index)
  route_table_id = aws_route_table.private_route_table[1].id
}
