resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "Manages connections to ${var.name} redis cache"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                 = "${var.name}-redis",
    "Managed By Terraform" = "true"
  }
}

resource "aws_security_group_rule" "redis_ingress_6379_instances" {
  description              = "Redis connections from instances"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_ingress_6379_bastion" {
  description              = "Redis connections from bastion"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.db.bastion_sg
  security_group_id        = aws_security_group.redis.id
}
