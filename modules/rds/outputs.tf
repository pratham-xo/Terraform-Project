output "rds_endpoints" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_name" {
  value = aws_db_instance.mysql.db_name
}