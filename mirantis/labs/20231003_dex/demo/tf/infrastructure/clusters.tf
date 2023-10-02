module "labs_dex" {
  source = "../modules/k0s-aws"

  name             = "mnirtl-labs"
  zone             = "mirantis.mart.red"
  controller_count = 3
  worker_count     = 3
  instance_type    = "t3.xlarge"
  vpc_id           = data.aws_vpc.default.id
  ssh_key_path     = local.key_path
  ssh_key_name     = local.key_name
  ssh_key          = tls_private_key.ssh_key_pair.public_key_openssh
  local_dir_path   = "${path.root}/.local/mnirtl-labs"
  oidc_issuer_url  = "https://dex.apps.mnirtl-labs.mirantis.mart.red"

  common_tags = var.common_tags
}
