resource "aws_db_instance" "postgresql" {
  allocated_storage          = var.db.allocated_storage
  apply_immediately          = true
  auto_minor_version_upgrade = false
  backup_retention_period    = 7
  backup_window              = "04:00-04:30"
  db_subnet_group_name       = aws_db_subnet_group.postgresql.name
  engine                     = "postgres"
  engine_version             = var.db.engine_version
  identifier                 = var.name
  instance_class             = var.db.node_type
  multi_az                   = true
  name                       = "terraform"
  password                   = random_password.postgresql_admin_password.result
  skip_final_snapshot        = true
  storage_encrypted          = true
  username                   = "administrator"
  vpc_security_group_ids     = [aws_security_group.database.id]

  kms_key_id = coalesce(
    var.db.kms_key_arn,
    try(module.database_encryption_key[0].kms_key.arn, null)
  )

  lifecycle {
    ignore_changes = [latest_restorable_time]
  }

  tags = merge(var.db.tags, {
    "Managed By Terraform" = "true"
  })
}

resource "aws_db_subnet_group" "postgresql" {
  name       = var.name
  subnet_ids = var.db.subnets

  tags = merge(var.db.tags, {
    "Managed By Terraform" = "true"
  })
}
