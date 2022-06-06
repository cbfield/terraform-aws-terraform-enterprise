resource "aws_security_group" "load_balancer" {
  name        = "${var.name}-load-balancer"
  description = "Manages traffic to/from ${var.name} load balancer"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                 = "${var.name}-load-balancer",
    "Managed By Terraform" = ""
  }
}

resource "aws_security_group_rule" "load_balancer_ingress_80" {
  description       = "HTTP access from web for HTTPS redirect"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.load_balancer.ingress_cidrs
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "load_balancer_ingress_443" {
  description       = "HTTPS access from web"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.load_balancer.ingress_cidrs
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "load_balancer_egress_443" {
  description              = "HTTPS access to instances"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.load_balancer.id
}
