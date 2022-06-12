resource "aws_iam_role" "instance_role" {
  name               = var.name
  assume_role_policy = file("${path.module}/files/assume-role-policy.json")

  inline_policy {
    name = "s3-object-readwrite"
    policy = templatefile("${path.module}/templates/iam-s3.json.tpl", {
      bucket = aws_s3_bucket.storage_bucket.arn
    })
  }

  inline_policy {
    name = "secretsmanager-getsecretvalue"
    policy = templatefile("${path.module}/templates/iam-secrets.json.tpl", {
      secrets = jsonencode([
        aws_secretsmanager_secret.secrets.arn,
        var.license_key_secret
      ])
    })
  }

  dynamic "inline_policy" {
    for_each = var.iam.policies == null ? {} : {
      for policy in var.iam.policies : policy.name => policy
    }

    content {
      name   = each.key
      policy = each.value.policy
    }
  }

  tags = merge(var.iam.tags, {
    "Managed By Terraform" = "true"
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.name
  role = aws_iam_role.instance_role.name
}
