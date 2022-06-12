resource "aws_launch_configuration" "launch_config" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  image_id                    = data.aws_ami.ami.id
  instance_type               = var.instances.type
  key_name                    = aws_key_pair.ec2_key.key_name
  name_prefix                 = var.name
  security_groups             = [aws_security_group.instances.id]
  user_data = templatefile("${path.module}/templates/ec2-user-data.sh.tpl", {
    domain_name       = var.domain_name
    license_secret_id = var.license_key_secret
    region            = data.aws_region.current.name
    secrets_id        = aws_secretsmanager_secret.secrets.id
    worker_image      = var.worker_image

    replicated_settings = templatefile("${path.module}/templates/ec2-replicated-settings.json.tpl", {
      hostname       = var.domain_name
      release_number = var.release_number
    })

    tfe_settings = templatefile("${path.module}/templates/ec2-tfe-settings.json.tpl", {
      capacity_concurrency = var.run_config.concurrency
      capacity_memory      = var.run_config.memory_mb
      custom_image_tag     = var.worker_image
      hostname             = var.domain_name
      iact_subnets         = join(",", [for subnet in data.aws_subnet.instance_subnets : subnet.cidr_block])
      pg_netloc            = "${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port}"
      redis_host           = aws_elasticache_replication_group.redis_cache.primary_endpoint_address
      region               = data.aws_region.current.name
      s3_bucket            = aws_s3_bucket.storage_bucket.bucket
      tbw_image            = var.worker_image == "hashicorp/build-worker:now" ? "default_image" : "custom_image"

      s3_kms_key = coalesce(
        var.s3.kms_key_arn,
        try(module.s3_encryption_key[0].kms_key.arn, null)
      )
    })
  })

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type = "standard"
    volume_size = "64"
    encrypted   = true
  }
}

resource "aws_autoscaling_group" "instances" {
  launch_configuration = aws_launch_configuration.launch_config.name
  max_size             = var.instances.max
  min_size             = var.instances.min
  name                 = var.name
  target_group_arns    = [aws_lb_target_group.port_443.arn]
  vpc_zone_identifier  = var.instances.subnets

  tags = flatten([
    {
      key                 = "PostgreSQL Database"
      value               = "postgresql://terraform@${aws_db_instance.postgresql.address}:5432/terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Launch Config"
      value               = aws_launch_configuration.launch_config.name
      propagate_at_launch = true
    },
    {
      key                 = "Managed By Terraform"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = var.name
      propagate_at_launch = true
    },
    {
      key                 = "Redis Cache"
      value               = "redis://terraform@${aws_elasticache_replication_group.redis_cache.primary_endpoint_address}:6379"
      propagate_at_launch = true
    },
    {
      key                 = "ssm"
      value               = "scanonly"
      propagate_at_launch = true
    },
    {
      key                 = "Storage Bucket"
      value               = "s3://${aws_s3_bucket.storage_bucket.id}/"
      propagate_at_launch = true
    },
    ], [
    for k, v in var.instances.tags : {
      key                 = k
      value               = v
      propagate_at_launch = true
    }
    ]
  )

  lifecycle {
    create_before_destroy = true
  }
}
