# terraform/modules/secrets/main.tf
resource "aws_secretsmanager_secret" "db" {
  name = "app/${var.env}/db-credentials"
  recovery_window_in_days = 0
  tags = { name = "csgtest" }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = var.db_password
  })
}

output "secret_arn" { value = aws_secretsmanager_secret.db.arn }