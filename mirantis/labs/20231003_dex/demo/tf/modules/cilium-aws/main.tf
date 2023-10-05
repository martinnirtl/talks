resource "aws_security_group" "cilium" {
  name   = "${var.cluster_name}-cilium"
  vpc_id = var.vpc_id

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# TODO add right in-/egress rules
resource "aws_vpc_security_group_ingress_rule" "cilium" {
  security_group_id            = aws_security_group.cilium.id
  description                  = "Allow all traffic"
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.cilium.id
}
