output "platform_sg_id" {
    value = aws_security_group.keycloak_sg.id
  
}

output "platform_alb_sg_id" {
    value = aws_security_group.mediator_alb_sg.id
  
}

output "platform_db_sg_id" {
    value = aws_security_group.platform_db_sg.id
  
}

output "mediator_sg_id" {
    value = aws_security_group.mediator_sg.id 
}

output "mediator_alb_sg_id" {
    value = aws_security_group.mediator_alb_sg.id
  
}

output "mediator_db_sg_id" {
    value = aws_security_group.mediator_db_sg.id
  
}

output "keycloak_sg_id" {
    value = aws_security_group.keycloak_sg.id
  
}

output "keycloak_alb_sg_id" {
    value = aws_security_group.keycloak_alb_sg.id
  
}

output "keycloak_db_sg_id" {
    value = aws_security_group.keycloak_db_sg.id
  
}

output "credo_db_sg_id" {
    value = aws_security_group.credo_db_sg.id
  
}

output "basion_sg_id" {
    value = aws_security_group.basion_sg.id
  
}

output "efs_sg_id" {
    value = aws_security_group.efs_sg.id
  
}
output "nats_security_group_ids" {
  description = "The security group IDs for NATS servers."
  value = {
    for key,sg in aws_security_group.nats_security_group : key => sg.id
  }
}

# Saving the output to a local file
resource "local_file" "nats_security_group_output" {
  content  = join("\n", [for key, sg in aws_security_group.nats_security_group : "${key}: ${sg.id}"])
  filename = "${path.module}/nats_security_group_ids.txt"
}

output "platform_db_port" {
  value = var.db_port.platform_db_port
}

output "credo_db_port" {
  value = var.db_port.credo_db_port
}

output "mediator_db_port" {
  value = var.db_port.mediator_db_port
}
output "keycloak_db_port" {
  value = var.db_port.keycloak_db_port
}