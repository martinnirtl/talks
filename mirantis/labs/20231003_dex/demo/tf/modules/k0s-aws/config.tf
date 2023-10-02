module "k0s_config" {
  source = "../k0s-config"

  name                       = var.name
  controllers                = [for host in aws_instance.static_controller : host.public_ip]
  workers                    = [for host in aws_instance.static_worker : host.public_ip]
  api_fqdn                   = aws_route53_record.k8s_api.fqdn
  oidc_issuer_url            = var.oidc_issuer_url
  service_account_issuer_url = "https://${aws_s3_bucket.openid.bucket_domain_name}"
  ssh_key_path               = var.ssh_key_path
}

resource "local_file" "k0s_config" {
  file_permission = "0600"
  filename        = "${var.local_dir_path}/k0sctl-config.yaml"
  content         = module.k0s_config.k0sctl_config
}

resource "null_resource" "k0sctl_apply" {
  triggers = { k0s_config_sha = sha256(module.k0s_config.k0sctl_config) }

  provisioner "local-exec" {
    command     = "k0sctl apply --config ${var.local_dir_path}/k0sctl-config.yaml --kubeconfig-out ${var.local_dir_path}/kubeconfig.yaml"
    interpreter = ["bash", "-c"]
  }

  depends_on = [module.k0s_config.k0sctl_config]
}
