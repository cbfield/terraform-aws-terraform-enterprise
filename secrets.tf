resource "aws_secretsmanager_secret" "secrets" {
  name        = "${var.name}-secrets"
  description = "keys and passwords for ${var.name} to connect to peripheral resources"

  tags = {
    "Managed By Terraform" = "true",
    "Name"                 = var.name
  }
}

resource "aws_secretsmanager_secret_version" "secret_values" {
  secret_id = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode({
    db_password      = random_password.postgresql_terraform_password.result,
    encryption_key   = random_uuid.encryption_key.result,
    redis_auth_token = random_password.redis_auth_token.result,
  })
}

resource "random_uuid" "encryption_key" {}

resource "random_password" "postgresql_admin_password" {
  length  = 16
  special = false
}

resource "random_password" "postgresql_terraform_password" {
  length  = 16
  special = false
}

resource "random_password" "redis_auth_token" {
  length  = 16
  special = false
}
