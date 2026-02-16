# secrets.tf

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}/database-credentials"
  description = "Database credentials for Catalogix PostgreSQL database"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}