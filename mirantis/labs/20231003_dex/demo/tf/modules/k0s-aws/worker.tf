resource "aws_security_group" "data_plane" {
  name   = "${var.name}-data-plane"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      "kubernetes.io/cluster/${var.name}" = null,
    }
  )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_worker" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Allow SSH access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "kube_router" {
  security_group_id            = aws_security_group.data_plane.id
  description                  = "Allow kuberouter traffic on data plane"
  from_port                    = 179
  to_port                      = 179
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.data_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "calico" {
  security_group_id            = aws_security_group.data_plane.id
  description                  = "Allow calico traffic on data plane"
  from_port                    = 4789
  to_port                      = 4789
  ip_protocol                  = "udp"
  referenced_security_group_id = aws_security_group.data_plane.id
}

# TODO required?
resource "aws_vpc_security_group_ingress_rule" "kubelet_worker" {
  security_group_id            = aws_security_group.data_plane.id
  description                  = "Allow kubelet access on data plane"
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.data_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "worker_ingress_controller_http" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Allow HTTP"
  from_port         = 32080
  to_port           = 32080
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

resource "aws_vpc_security_group_ingress_rule" "worker_ingress_controller_https" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Allow HTTP"
  from_port         = 32443
  to_port           = 32443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

# TODO required?
resource "aws_vpc_security_group_ingress_rule" "all_worker" {
  security_group_id            = aws_security_group.data_plane.id
  description                  = "Allow all traffic on data plane"
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.data_plane.id
}

# TODO required?
resource "aws_vpc_security_group_ingress_rule" "all_worker_from_controller_all" {
  security_group_id            = aws_security_group.data_plane.id
  description                  = "Allow all traffic from control plane"
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.control_plane.id
}

resource "aws_vpc_security_group_egress_rule" "all_worker" {
  security_group_id = aws_security_group.data_plane.id
  description       = "Allow all traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}

resource "random_uuid" "static_worker_nodepool" {}

resource "aws_instance" "static_worker" {
  count = var.worker_count

  launch_template {
    id = aws_launch_template.node.id
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  subnet_id              = data.aws_subnets.subnets.ids[count.index % length(data.aws_subnets.subnets.ids)]
  vpc_security_group_ids = [aws_security_group.data_plane.id, module.aws_cilium.security_group_id]

  # TODO use IRSA (see https://github.com/kubernetes/cloud-provider-aws/issues/327)
  # iam_instance_profile = "AWSCloudControllerManagerNodeProfile"

  tags = merge(
    var.common_tags,
    {
      "kubernetes.io/cluster/${var.name}" = "owned"
      # "KubernetesCluster" = random_uuid.cluster.id
      "NodePool" = random_uuid.static_worker_nodepool.id
      "Role"     = "worker"
    }
  )

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}
