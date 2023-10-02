resource "aws_iam_role" "aws_ebs" {
  name = "AmazonEBSCSIDriverRole"
  path = "/mnirtl/${var.name}/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Federated" : "${aws_iam_openid_connect_provider.cluster.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" : {
            "${aws_s3_bucket.openid.bucket_domain_name}:sub" : "system:serviceaccount:aws-ebs:ebs-csi-controller-sa",
            "${aws_s3_bucket.openid.bucket_domain_name}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_ebs" {
  role       = aws_iam_role.aws_ebs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_policy" "external_dns" {
  name = "ExternalDNSPolicy"
  path = "/mnirtl/${var.name}/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role" "external_dns" {
  name = "ExternalDNSRole"
  path = "/mnirtl/${var.name}/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Federated" : "${aws_iam_openid_connect_provider.cluster.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" : {
            "${aws_s3_bucket.openid.bucket_domain_name}:sub" : "system:serviceaccount:external-dns:external-dns",
            "${aws_s3_bucket.openid.bucket_domain_name}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
