resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "csgtest-db-secret"

  tags = {
    Name = "csgtest"
  }
}

resource "aws_secretsmanager_secret_version" "db_version" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}