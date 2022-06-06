resource "aws_iam_role" "instance_role" {
  name               = "${var.name}-instance-role"
  assume_role_policy = file("${path.module}/files/assume-role-policy.json")

  inline_policy {
    name = "${var.name}-storage-bucket-access"
    policy = templatefile("${path.module}/templates/iam-bucket-access.json.tpl", {
      bucket = aws_s3_bucket.storage_bucket.arn
    })
  }

  inline_policy {
    name = "${var.name}-secrets-access"
    policy = templatefile("${path.module}/templates/iam-secrets-access.json.tpl", {
      secrets = jsonencode([
        aws_secretsmanager_secret.secrets.arn,
        var.license_key_secret
      ])
    })
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_policy" "iam_policy" {
  for_each = { for policy in var.instance_profile_policies : policy.name => policy }

  name   = each.key
  policy = each.value.policy
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  for_each = { for policy in aws_iam_policy.iam_policy : policy.name => policy }

  role       = aws_iam_role.instance_role.name
  policy_arn = each.value.arn
}
