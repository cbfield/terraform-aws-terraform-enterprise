resource "aws_s3_bucket" "storage_bucket" {
  bucket = "voynich-${var.name}"
  acl    = "private"
  policy = templatefile("${path.module}/templates/s3-bucket-policy.json.tpl", {
    bucket  = "voynich-${var.name}"
    kms_key = module.s3_encryption_key.kms_key.arn
  })

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.s3_encryption_key.kms_key.arn
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
