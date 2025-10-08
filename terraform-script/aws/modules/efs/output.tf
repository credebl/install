output "credo_efs_id" {
  value = aws_efs_file_system.credo_efs.id

}
output "credo_efs_arn" {
  value = aws_efs_file_system.credo_efs.arn
}

output "credo_efs_dns" {
  value = aws_efs_file_system.credo_efs.dns_name
}

output "nats_efs_id" {
  value = aws_efs_file_system.nats_efs.id

}
output "nats_efs_arn" {
  value = aws_efs_file_system.nats_efs.arn
}

output "nats_efs_dns" {
  value = aws_efs_file_system.nats_efs.dns_name
}

output "nats_efs_access_point_id" {
  value = aws_efs_access_point.nats_access_point.id
}
