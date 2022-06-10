resource "aws_s3_bucket" "storage_bucket" {
  bucket_prefix = var.name
  acl           = "private"

  policy = templatefile("${path.module}/templates/s3-bucket-policy.json.tpl", {
    bucket = var.name
    kms_key = coalesce(
      var.s3.kms_key_arn,
      try(module.s3_encryption_key.kms_key.arn, null)
    )
  })

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = coalesce(
          var.s3.kms_key_arn,
          try(module.s3_encryption_key[0].kms_key.arn, null)
        )
      }
    }
  }

  tags = {
    "Managed By Terraform" = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_owner_preferred" {
  bucket = aws_s3_bucket.storage_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
