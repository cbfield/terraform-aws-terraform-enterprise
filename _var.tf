variable "acm_cert_arn" {
  description = "An ACM cert to use to encrypt traffic to TFE"
  type        = string
  default     = ""
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
  })
}

variable "domain_name" {
  description = "The domain name to use for the service"
  type        = string
}

variable "instance_profile_policies" {
  description = "IAM policies to attach to the instance profile that is used by the instances"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "instances" {
  description = "Configurations of the autoscaling group that manages the instances"
  type = object({
    bastion_sg     = string
    max            = number
    min            = number
    subnets        = list(string)
    ssh_public_key = optional(string)
    type           = string
  })
}

variable "license_key_secret" {
  description = "The ARN of a Secrets Manager secret containing the .rli file for the TFE license"
  type        = string
}

variable "load_balancer" {
  description = "CIDRs from which to allow traffic, and subnets to place the load balancer in"
  type = object({
    ingress_cidrs = list(string)
    subnets       = list(string)
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
