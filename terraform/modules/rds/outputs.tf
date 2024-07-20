
output "rds_security_group_id" {
  description = "The ID of the security group associated with the RDS instance"
  value       = aws_security_group.rds_sg.id
}

output "rds_db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.private_db_subnet.name
}

output "rds_instance_identifier" {
  description = "The identifier of the RDS instance"
  value       = aws_db_instance.rds.identifier
}

output "rds_instance_status" {
  description = "The current status of the RDS instance"
  value       = aws_db_instance.rds.status
}

output "rds_instance_storage_encrypted" {
  description = "Whether storage is encrypted for the RDS instance"
  value       = aws_db_instance.rds.storage_encrypted
}

# Define o output para o endpoint do RDS
output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}
