resource "aws_lb" "load_balancer" {
  enable_cross_zone_load_balancing = true
  name                             = var.name
  idle_timeout                     = 1200
  internal                         = true
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.load_balancer.id]
  subnets                          = var.load_balancer.subnets

  tags = merge(var.load_balancer.tags, {
    "Managed By Terraform" = "true"
  })
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.acm_cert_arn != null || var.acm != null ? [1] : []

    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.acm_cert_arn == null && var.acm == null ? [1] : []

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.port_443.arn
    }
  }
}

resource "aws_lb_listener" "port_443" {
  count = var.acm_cert_arn != null || var.acm != null ? 1 : 0

  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  certificate_arn = coalesce(
    var.acm_cert_arn,
    try(module.acm_cert[0].certificate.arn, null)
  )

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_443.arn
  }
}

resource "aws_lb_target_group" "port_443" {
  name     = "${var.name}-443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    matcher  = "200"
    protocol = "HTTPS"
    path     = "/_health_check?full=1"
  }
}
