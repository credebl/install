output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_app_subnet_ids" {
  description = "The IDs of the private subnets for app"
  value       = aws_subnet.private_subnet_app[*].id
}

output "private_db_subnet_ids" {
  description = "The IDs of the private subnets for database"
  value       = aws_subnet.private_subnet_db[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "availability_zone" {
  value = var.availability_zone

}
