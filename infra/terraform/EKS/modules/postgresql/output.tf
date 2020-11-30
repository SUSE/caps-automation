output "fqdn" {
  value = aws_rds_cluster_instance.postgresql.endpoint
}

output "login" {
  value = aws_rds_cluster.aurora.master_username
}

output "password" {
  value = random_password.db_password.result
}
