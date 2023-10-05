data "aws_route53_zone" "primary" {
  name = var.zone
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  file_permission = "600"
  filename        = "${var.local_dir_path}/ssh_key.pem"
  content         = tls_private_key.ssh.private_key_pem
}

resource "aws_key_pair" "ssh" {
  key_name   = var.name
  public_key = tls_private_key.ssh.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_launch_template" "node" {
  name          = "${var.name}-node"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name
  user_data     = filebase64("${path.module}/user-data/node.sh")

  ebs_optimized = true
  block_device_mappings {
    device_name = data.aws_ami.ubuntu.root_device_name

    ebs {
      volume_size           = 40
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      image_id, tags, user_data
    ]
  }
}
