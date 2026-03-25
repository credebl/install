output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
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

output "availability_zone" {
  value = data.aws_availability_zones.available_zones
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}