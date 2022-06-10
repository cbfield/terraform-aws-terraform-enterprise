resource "aws_elasticache_replication_group" "redis_cache" {
  apply_immediately             = true
  at_rest_encryption_enabled    = true
  auth_token                    = random_password.redis_auth_token.result
  automatic_failover_enabled    = true
  engine_version                = var.redis.engine_version
  multi_az_enabled              = true
  node_type                     = var.redis.node_type
  number_cache_clusters         = length(var.redis.subnets)
  replication_group_description = "${var.name} application cache, manages app state between instances"
  replication_group_id          = var.name
  security_group_ids            = [aws_security_group.redis.id]
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  transit_encryption_enabled    = true

  kms_key_id = coalesce(
    var.redis.kms_key_arn,
    try(module.redis_encryption_key[0].kms_key.arn, null)
  )

  tags = {
    "Managed By Terraform" = "true"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = var.name
  subnet_ids = var.redis.subnets

  tags = {
    "Managed By Terraform" = "true"
  }
}
