module "acm_cert" {
  source  = "app.terraform.io/Bucketmeadow/acm-certificate/aws"
  version = "1.0.0"
  count   = var.acm_cert_arn == null && var.acm != null ? 1 : 0

  domain  = var.domain_name
  zone_id = var.acm.zone_id

  validation_method = coalesce(var.acm.validation_method, "DNS")
  validate          = coalesce(var.acm.validate, true)

  tags = var.acm.tags
}
