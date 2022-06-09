resource "aws_security_group" "instances" {
  name        = "${var.name}-instances"
  description = "Manages traffic to/from ${var.name} instances"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                 = "${var.name}-instances",
    "Managed By Terraform" = "true"
  }
}

resource "aws_security_group_rule" "instances_ingress_22" {
  description              = "SSH access from bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.instances.bastion_sg
  security_group_id        = aws_security_group.instances.id
}

resource "aws_security_group_rule" "instances_ingress_443" {
  description              = "HTTPS traffic from load balancer"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.instances.id
}

resource "aws_security_group_rule" "instances_ingress_8201" {
  description       = "Vault HA request forwarding between instances"
  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.instances.id
}

resource "aws_security_group_rule" "instances_egress" {
  description       = "Web requests for installer packages and update checks"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances.id
}
