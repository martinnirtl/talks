resource "aws_s3_bucket" "openid" {
  bucket = "${var.name}-oidc"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "openid" {
  bucket = aws_s3_bucket.openid.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "openid" {
  bucket = aws_s3_bucket.openid.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "random_uuid" "rand" {}

resource "null_resource" "openid_configuration" {
  triggers = { run_once = random_uuid.rand.id }

  provisioner "local-exec" {
    command     = "kubectl --kubeconfig ${var.local_dir_path}/kubeconfig.yaml get --raw /.well-known/openid-configuration > ${var.local_dir_path}/openid-configuration.json"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.k0sctl_apply]
}

resource "null_resource" "openid_jwks" {
  triggers = { run_once = random_uuid.rand.id }

  provisioner "local-exec" {
    command     = "kubectl --kubeconfig ${var.local_dir_path}/kubeconfig.yaml get --raw /openid/v1/jwks > ${var.local_dir_path}/openid-jwks.json"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.k0sctl_apply]
}

resource "aws_s3_object" "openid_configuration" {
  bucket = aws_s3_bucket.openid.id
  key    = ".well-known/openid-configuration"
  source = "${var.local_dir_path}/openid-configuration.json"
  # content      = <<-EOF
  #   {
  #     "issuer":"${var.bucket_domain_name}",
  #     "jwks_uri":"${var.bucket_domain_name}/openid/v1/jwks",
  #     "response_types_supported":[
  #       "id_token"
  #     ],
  #     "subject_types_supported":[
  #       "public"
  #     ],
  #     "id_token_signing_alg_values_supported":[
  #       "RS256"
  #     ]
  #   }
  # EOF
  content_type = "application/json"
  acl          = "public-read"

  # etag = filemd5("${var.local_dir_path}/openid-configuration.json")

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [null_resource.openid_configuration]
}

resource "aws_s3_object" "jwks" {
  bucket = aws_s3_bucket.openid.id
  key    = "openid/v1/jwks"
  source = "${var.local_dir_path}/openid-jwks.json"
  # content      = <<-EOF
  #   {
  #     "keys":[
  #       {
  #         "use":"sig",
  #         "kty":"RSA",
  #         "kid":"${md5(tls_private_key.serviceaccount_signer.private_key_pem)}",
  #         "alg":"RS256",
  #         "n":"vh5ZxxKhOzZwyvMo84x_Np8Jf50zzEFtVPzKGMmeJBJ50BjSg_EWORaFU7xdNGaCdagERswKcRfA2IdJhrIn5o3IzNqgkCri0xCVtr25a-hF3w6Mlg-oPPtW2rS7t0XlbYJBedMjG_eQ5kBr-MFuYjDKA0hZNqhuk00O_p-cRsVFB1TF4uiVjdz7tKPxK2nuqALZL4zknizC0nTJEh2PfEPAPu3O_JHCYLenwktLZChxupVnlZsLGrMde_xEN7bUxYYld8OHNnSaTg7TuhXqmXKKvAGou9KhAiZsK37wCDO7vZ_92cWKYscLzgFsyE0esWJ6oOG6FjvJNUAGW7Z8_OhkJ_fHBymZ6n_eFJP2lODvX_2K-18cGdhuBcf5kQd7VvUlf2TdY1-wVR2GDoAxLbzPo_p265u0tLKN1sz0Z7Dpa7TF_FmRGYeKAQuPTUrncnRwDdvUpJWCsdJOxI49vcr27_eof-WoaSekZaGqEh6D15qdx2Wc1YJfL5NlDmo3Bq10mRkM3RP9Z0K84tOw9utc8rOOGir320pUDtLSwmXVZHvqHZLcPD-qEW0jonAa3nNxZHP07g7279eDVcpxCD28yq9SC6BdKGrXy8gkYrbF_RTaAniVNPVb5YREe616537_ezemVdagsakO8-iZAwJkJ9c5FgwB3vLCm6H5SiE",
  #         "e":"AQAB"
  #       }
  #     ]
  #   }
  # EOF
  content_type = "application/json"
  acl          = "public-read"

  # etag = filemd5("${var.local_dir_path}/openid-jwks.json")

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [null_resource.openid_jwks]
}

data "tls_certificate" "openid_bucket" {
  url = "https://${aws_s3_bucket.openid.bucket_domain_name}"
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url             = "https://${aws_s3_bucket.openid.bucket_domain_name}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.openid_bucket.certificates[0].sha1_fingerprint]
}
