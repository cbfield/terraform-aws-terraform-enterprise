data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami.name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = var.ami.owners
}

# To retrieve CIDRs, used in TFE application configuration
data "aws_subnet" "instance_subnets" {
  for_each = toset(var.instances.subnets)

  id = each.value
}
