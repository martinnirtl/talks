locals {
  key_name = "mnirtl-labs"
  key_path = "${path.module}/.local/ssh.pem"
}

data "aws_vpc" "default" {
  default = true
}
