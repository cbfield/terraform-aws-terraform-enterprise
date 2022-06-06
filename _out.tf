output "acm_cert_arn" {
  description = "The value provided for var.acm_cert_arn"
  value       = var.acm_cert_arn
}

output "ami" {
  description = "The given value for var.ami"
  value       = var.ami
}

output "autoscaling_group" {
  description = "The autoscaling group hosting the service"
  value       = aws_autoscaling_group.instances
}

output "aws_caller_identity" {
  description = "The AWS caller identity used to manage this module"
  value       = data.aws_caller_identity.current
}

output "aws_region" {
  description = "The AWS region containing this module"
  value       = data.aws_region.current
}

output "db" {
  description = "The database used by the service"
  value = {
    instance     = aws_db_instance.postgresql
    subnet_group = aws_db_subnet_group.postgresql
  }
}

output "db_admin_password" {
  description = "The password for the admin user in the database"
  value       = random_password.postgresql_admin_password
  sensitive   = true
}

output "domain_name" {
  description = "The given value for var.domain_name"
  value       = var.domain_name
}

output "ec2_key" {
  description = "The EC2 key used for SSH authentication on the instances"
  value       = aws_key_pair.ec2_key
}

output "instance_profile" {
  description = "The role used to create the instance profile used by the service"
  value       = aws_iam_instance_profile.instance_profile
}

output "instance_profile_policies" {
  description = "The given value for var.instance_profile_policies"
  value       = var.instance_profile_policies
}

output "instance_role" {
  description = "The role used to create the instance profile used by the service"
  value       = aws_iam_role.instance_role
}

output "instances" {
  description = "The given value for var.instances"
  value       = var.instances
}

output "kms_keys" {
  description = "KMS keys used by the module"
  value = {
    s3       = module.s3_encryption_key
    database = module.database_encryption_key
    redis    = module.redis_encryption_key
  }
}

output "launch_configuration" {
  description = "The launch configuration used by the autoscaling group hosting the service"
  value       = aws_launch_configuration.launch_config
}

output "load_balancer" {
  description = "The load balancer resource, as well as the associated listeners and target groups. If var.acm_cert_arn was not provided, this also outputs the ssl cert created for the listeners"
  value = {
    balancer = aws_lb.load_balancer
    listeners = {
      "80"  = aws_lb_listener.port_80
      "443" = aws_lb_listener.port_443
    }
    ssl_cert = var.acm_cert_arn == "" ? aws_acm_certificate.cert.0 : null
    target_groups = {
      port_443 = aws_lb_target_group.port_443
    }
  }
}

output "name" {
  description = "The given value for var.name"
  value       = var.name
}

output "private_ca" {
  description = "The value provided for var.private_ca"
  value       = var.private_ca
}

output "redis" {
  description = "The Redis cache used by the service"
  value = {
    cache        = aws_elasticache_replication_group.redis_cache
    subnet_group = aws_elasticache_subnet_group.redis
  }
}

output "redis_auth_token" {
  description = "The auth token used to communicate with the Redis cache"
  value       = random_password.redis_auth_token
  sensitive   = true
}

output "release_number" {
  description = "The value provided for var.release_number"
  value       = var.release_number
}

output "run_config" {
  description = "The provided value for var.run_config"
  value       = var.run_config
}

output "s3" {
  description = "The S3 bucket used by the service to store objects, and associated configurations"
  value = {
    bucket             = aws_s3_bucket.storage_bucket
    acl                = aws_s3_bucket_public_access_block.block_public_access
    ownership_controls = aws_s3_bucket_ownership_controls.bucket_owner_preferred
  }
}

output "security_groups" {
  description = "Security groups used by the module"
  value = {
    instances     = aws_security_group.instances
    load_balancer = aws_security_group.load_balancer
    database      = aws_security_group.database
    redis         = aws_security_group.redis
  }
}

output "ssh_key" {
  description = "The key PEM used to generate the EC2 key for SSH authentication on the instances"
  value       = tls_private_key.ssh_key
  sensitive   = true
}

output "vpc_id" {
  description = "The given value for var.vpc_id"
  value       = var.vpc_id
}

output "worker_image" {
  description = "The value provided for var.worker_image"
  value       = var.worker_image
}
