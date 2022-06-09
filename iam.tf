resource "aws_iam_role" "instance_role" {
  name               = var.name
  assume_role_policy = file("${path.module}/files/assume-role-policy.json")

  inline_policy {
    name = "${var.name}-s3"
    policy = templatefile("${path.module}/templates/iam-s3.json.tpl", {
      bucket = aws_s3_bucket.storage_bucket.arn
    })
  }

  inline_policy {
    name = "${var.name}-secrets"
    policy = templatefile("${path.module}/templates/iam-secrets.json.tpl", {
      secrets = jsonencode([
        aws_secretsmanager_secret.secrets.arn,
        var.license_key_secret
      ])
    })
  }

  dynamic "inline_policy" {
    for_each = { for policy in var.instance_profile_policies : policy.name => policy }

    content {
      name   = each.key
      policy = each.value.policy
    }
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.name
  role = aws_iam_role.instance_role.name
}
