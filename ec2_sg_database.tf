resource "aws_security_group" "database" {
  name        = "${var.name}-database"
  description = "Manages connections to ${var.name} database"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                 = "${var.name}-database",
    "Managed By Terraform" = "true"
  }
}

resource "aws_security_group_rule" "database_ingress_5432_instances" {
  description              = "PostgreSQL connections from instances"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.database.id
}

resource "aws_security_group_rule" "database_ingress_5432_bastion" {
  description              = "PostgreSQL connections from bastion"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.db.bastion_sg
  security_group_id        = aws_security_group.database.id
}
