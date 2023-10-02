resource "aws_security_group" "control_plane" {
  name   = "${var.name}-control-plane"
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

resource "aws_vpc_security_group_ingress_rule" "ssh_controller" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow ssh access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "etcd_peers" {
  security_group_id            = aws_security_group.control_plane.id
  description                  = "Allow etcd traffic on control plane"
  from_port                    = 2380
  to_port                      = 2380
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.control_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow kube-api access"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

resource "aws_vpc_security_group_ingress_rule" "konnectivity_controller" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow konnectivity agents traffic from data plane"
  from_port         = 8132
  to_port           = 8132
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

resource "aws_vpc_security_group_ingress_rule" "k0s_api" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow k0s-api access"
  from_port         = 9443
  to_port           = 9443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}


# TODO required?
resource "aws_vpc_security_group_ingress_rule" "kubelet_controller" {
  security_group_id            = aws_security_group.control_plane.id
  description                  = "Allow kubelet access on control plane"
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.control_plane.id
}

# resource "aws_vpc_security_group_ingress_rule" "all_controller" {
#   security_group_id            = aws_security_group.control_plane.id
#   description                  = "Allow all traffic on control plane"
#   from_port                    = -1
#   to_port                      = -1
#   ip_protocol                  = -1
#   referenced_security_group_id = aws_security_group.control_plane.id
# }

resource "aws_vpc_security_group_ingress_rule" "controller_ingress_controller_http" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow HTTP"
  from_port         = 32080
  to_port           = 32080
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

resource "aws_vpc_security_group_ingress_rule" "controller_ingress_controller_https" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow HTTP"
  from_port         = 32443
  to_port           = 32443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
}

resource "aws_vpc_security_group_egress_rule" "all_controller" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow all traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}

resource "random_uuid" "static_controller_nodepool" {}

resource "aws_instance" "static_controller" {
  count = var.controller_count

  launch_template {
    id = aws_launch_template.node.id
  }

  subnet_id              = data.aws_subnets.subnets.ids[count.index % length(data.aws_subnets.subnets.ids)]
  vpc_security_group_ids = [aws_security_group.control_plane.id, module.aws_cilium.security_group_id]

  # TODO use IRSA (see https://github.com/kubernetes/cloud-provider-aws/issues/327)
  # iam_instance_profile = "AWSCloudControllerManagerControlPlaneProfile"

  tags = merge(
    var.common_tags,
    {
      "kubernetes.io/cluster/${var.name}" = "owned"
      # "KubernetesCluster" = random_uuid.cluster.id
      "NodePool" = random_uuid.static_controller_nodepool.id
      "Role"     = "controller"
    }
  )

  lifecycle {
    ignore_changes = [tags, user_data]
  }
}

resource "aws_lb_listener" "k8s_api" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.k8s_api.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "k8s_api" {
  name     = "${var.name}-k8s-api-lbtg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "k8s_api_static" {
  count = var.controller_count

  target_group_arn = aws_lb_target_group.k8s_api.arn
  target_id        = aws_instance.static_controller[count.index].id
  port             = 6443
}

resource "aws_lb_listener" "konnectivity" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = 8132
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.konnectivity.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "konnectivity" {
  name     = "${var.name}-konnectivity-lbtg"
  port     = 8132
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "konnectivity_static" {
  count = var.controller_count

  target_group_arn = aws_lb_target_group.konnectivity.arn
  target_id        = aws_instance.static_controller[count.index].id
  port             = 8132
}

resource "aws_lb_listener" "k0s_api" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = 9443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.k0s_api.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "k0s_api" {
  name     = "${var.name}-k0s-api-lbtg"
  port     = 9443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "k0s_api_static" {
  count = var.controller_count

  target_group_arn = aws_lb_target_group.k0s_api.arn
  target_id        = aws_instance.static_controller[count.index].id
  port             = 9443
}

output "k8s_api" {
  value = aws_lb.cluster.dns_name
}
