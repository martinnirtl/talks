locals {
  key_name = var.cluster_name
  key_path = "${path.module}/.local/ssh.pem"
}

data "aws_vpc" "default" {
  default = true
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  file_permission = "600"
  filename        = local.key_path
  content         = tls_private_key.ssh_key_pair.private_key_pem
}
