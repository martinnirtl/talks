resource "random_uuid" "cluster" {}

resource "aws_lb" "cluster" {
  name               = "${var.name}-cluster-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = slice(data.aws_subnets.subnets.ids, 0, 3)

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_route53_record" "k8s_api" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "kubernetes.${var.name}"
  type    = "A"

  alias {
    name                   = aws_lb.cluster.dns_name
    zone_id                = aws_lb.cluster.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apps" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "*.apps.${var.name}"
  type    = "A"

  alias {
    name                   = aws_lb.cluster.dns_name
    zone_id                = aws_lb.cluster.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "ingress_controller_http" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.ingress_controller_http.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ingress_controller_http" {
  name     = "${var.name}-ingress-http-lbtg"
  port     = 32080
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "ingress_controller_http_static_controller" {
  count = var.controller_count

  target_group_arn = aws_lb_target_group.ingress_controller_http.arn
  target_id        = aws_instance.static_controller[count.index].id
  port             = 32080
}
resource "aws_lb_target_group_attachment" "ingress_controller_http_static_worker" {
  count = var.worker_count

  target_group_arn = aws_lb_target_group.ingress_controller_http.arn
  target_id        = aws_instance.static_worker[count.index].id
  port             = 32080
}

resource "aws_lb_listener" "ingress_controller_https" {
  load_balancer_arn = aws_lb.cluster.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.ingress_controller_https.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ingress_controller_https" {
  name     = "${var.name}-ingress-https-lbtg"
  port     = 32443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "ingress_controller_https_static_controller" {
  count = var.controller_count

  target_group_arn = aws_lb_target_group.ingress_controller_https.arn
  target_id        = aws_instance.static_controller[count.index].id
  port             = 32443
}
resource "aws_lb_target_group_attachment" "ingress_controller_https_static_worker" {
  count = var.worker_count

  target_group_arn = aws_lb_target_group.ingress_controller_https.arn
  target_id        = aws_instance.static_worker[count.index].id
  port             = 32443
}

module "aws_cilium" {
  source = "../cilium-aws"

  cluster_name = var.name
  vpc_id       = var.vpc_id
  common_tags  = var.common_tags
}
