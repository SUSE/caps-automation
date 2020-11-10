output "fqdn" {
  value = aws_db_instance.postgresql.address
}

output "login" {
  value = aws_db_instance.postgresql.username
}

output "password" {
  value = random_password.db_password.result
}
