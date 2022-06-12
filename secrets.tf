resource "aws_secretsmanager_secret" "secrets" {
  name        = var.name
  description = "keys and passwords for ${var.name} to connect to peripheral resources"

  tags = merge(var.secrets.tags, {
    "Managed By Terraform" = "true",
    "Name"                 = var.name
  })
}

resource "aws_secretsmanager_secret_version" "secret_values" {
  secret_id = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode(merge({
    db_password = coalesce(
      var.secrets.pg_pwd_terraform,
      try(random_password.postgresql_terraform_password[0].result, null)
    )
    encryption_key = coalesce(
      var.secrets.enc_key,
      try(random_uuid.encryption_key[0].result, null)
    )
    redis_auth_token = coalesce(
      var.secrets.redis_pwd,
      try(random_password.redis_auth_token[0].result, null)
    )
    }, var.license_key_string != null ? {
    license_key = var.license_key_string
  } : {}))
}

resource "random_uuid" "encryption_key" {
  count = var.secrets.enc_key == null ? 1 : 0
}

resource "random_password" "postgresql_admin_password" {
  count = var.secrets.pg_pwd_admin == null ? 1 : 0

  length  = 16
  special = false
}

resource "random_password" "postgresql_terraform_password" {
  count = var.secrets.pg_pwd_terraform == null ? 1 : 0

  length  = 16
  special = false
}

resource "random_password" "redis_auth_token" {
  count = var.secrets.redis_pwd == null ? 1 : 0

  length  = 16
  special = false
}
