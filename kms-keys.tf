module "s3_encryption_key" {
  source  = "app.terraform.io/cbfield/kms-key/aws"
  version = "1.0.0"
  count   = var.s3.kms_key_arn == null ? 1 : 0

  alias     = "${var.name}-s3"
  key_users = [aws_iam_role.instance_role.arn]
  tags      = var.s3.tags
}

module "database_encryption_key" {
  source  = "app.terraform.io/cbfield/kms-key/aws"
  version = "1.0.0"
  count   = var.db.kms_key_arn == null ? 1 : 0

  alias = "${var.name}-database"
  tags  = var.db.tags
}

module "redis_encryption_key" {
  source  = "app.terraform.io/cbfield/kms-key/aws"
  version = "1.0.0"
  count   = var.redis.kms_key_arn == null ? 1 : 0

  alias = "${var.name}-redis"
  tags  = var.redis.tags
}
