output "iccsdb_hostname" {
  value       = aws_db_instance.iccsdb.address
  sensitive   = true
}

output "iccsdb_port" {
  value       = aws_db_instance.iccsdb.port
  sensitive   = true
}

output "iccdb_username" {
  value       = aws_db_instance.iccsdb.username
  sensitive   = true
}