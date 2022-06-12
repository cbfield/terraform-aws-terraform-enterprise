variable "acm_cert_arn" {
  description = <<-EOF
    The ARN of an ACM certificate that the module will use to encrypt traffic to TFE
    If provided, the module will not create its own cert. Conflicts with var.acm
  EOF
  type        = string
  default     = null
}

variable "acm" {
  description = <<-EOF
    Configurations for the ACM certificate created by the module
    Conflicts with var.acm_cert_arn
  EOF
  type = object({
    tags              = optional(map(string))
    validate          = optional(bool)
    validation_method = optional(string)
    zone_id           = string
  })
  default = null
}

variable "ami" {
  description = "The AMI to build each instance with"
  type = object({
    owners = list(string)
    name   = list(string)
  })
  default = {
    owners = ["amazon"]
    name   = ["amzn2-ami-hvm-2.0.20191116.0-x86_64-gp2"]
  }
}

variable "db" {
  description = "The subnet to place the database in, and the security group to allow connections from (in addition to connections from the service; this is for maintenance)"
  type = object({
    allocated_storage = number
    bastion_sg        = string
    engine_version    = string
    kms_key_arn       = optional(string)
    node_type         = string
    subnets           = list(string)
    tags              = optional(map(string))
  })
}

variable "domain_name" {
  description = "The domain name to use for the service"
  type        = string
}

variable "iam" {
  description = "IAM policies to associate with TFE's instance profile, and tags to assign to its role"
  type = object({
    policies = optional(list(object({
      name   = string
      policy = string
    })))
    tags = optional(map(string))
  })
  default = {}
}

variable "instances" {
  description = "Configurations of the autoscaling group that manages the instances"
  type = object({
    bastion_sg     = string
    max            = number
    min            = number
    subnets        = list(string)
    ssh_public_key = optional(string)
    tags           = optional(map(string))
    type           = string
  })
}

variable "license_key_secret" {
  description = <<-EOF
    The ARN of a Secrets Manager secret containing the .rli file for the TFE license
    Value must be accessed under key `license_key` in JSON secret
    Conflicts with var.license_key_string
  EOF
  type        = string
  default     = null
}

variable "license_key_string" {
  description = <<-EOF
    Base64-encoded string containing the TFE license key
    Conflicts with var.license_key_secret
  EOF
  type        = string
  default     = null
  validation {
    condition     = can(base64decode(var.license_key_string))
    error_message = "This value must be base64-encoded"
  }
}

variable "load_balancer" {
  description = "CIDRs from which to allow traffic, and subnets to place the load balancer in"
  type = object({
    ingress_cidrs = list(string)
    subnets       = list(string)
    tags          = optional(map(string))
  })
}

variable "name" {
  description = "The name to assign to all resources created by the module"
  type        = string
  default     = "terraform-enterprise"
}

variable "redis" {
  description = "Properties to assign to the Redis cache used by the application"
  type = object({
    engine_version = string
    kms_key_arn    = optional(string)
    node_type      = string
    subnets        = list(string)
    tags           = optional(map(string))
  })
}

variable "release_number" {
  description = "The release number of TFE to install. See README.md for releases page"
  type        = number
  default     = 568
}

variable "run_config" {
  description = "Configuration options for Terraform runs executed on TFE"
  type = object({
    memory_mb   = number
    concurrency = number
  })
  default = {
    memory_mb   = 512
    concurrency = 10
  }
}

variable "s3" {
  description = "Configurations for the S3 bucket used by Terraform Enterprise"
  type = object({
    bucket_policy = optional(string)
    kms_key_arn   = optional(string)
    tags          = optional(map(string))
  })
  default = {}
}

variable "secrets" {
  description = "Optional override values for secrets used by the module"
  type = object({
    enc_key          = optional(string)
    pg_pwd_admin     = optional(string)
    pg_pwd_terraform = optional(string)
    redis_pwd        = optional(string)
    tags             = optional(map(string))
  })
  default = {}
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create these resources"
  type        = string
}

variable "worker_image" {
  description = "The container image name and tag that TFE workers run when executing plans and applies"
  type        = string
  default     = "hashicorp/build-worker:now"
}
