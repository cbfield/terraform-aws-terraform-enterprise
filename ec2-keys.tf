resource "tls_private_key" "ssh_key" {
  count = var.instances.ssh_public_key ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name = var.name

  public_key = coalesce(
    var.instances.ssh_public_key,
    tls_private_key.ssh_key[0].public_key_openssh
  )
}
