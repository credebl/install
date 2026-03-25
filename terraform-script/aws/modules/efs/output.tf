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
  value = aws_efs_file_system.nats_efs[0].id
  description = "Primary NATS EFS ID"
}

output "nats_efs_ids" {
  value = aws_efs_file_system.nats_efs[*].id
  description = "All NATS EFS IDs for clustering"
}

output "nats_efs_arn" {
  value = aws_efs_file_system.nats_efs[0].arn
}

output "nats_efs_dns" {
  value = aws_efs_file_system.nats_efs[0].dns_name
}

output "seed_access_point_id" {
  value = aws_efs_access_point.seed_access_point.id
}
