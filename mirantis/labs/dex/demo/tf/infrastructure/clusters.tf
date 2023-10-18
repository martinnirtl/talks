module "labs_dex" {
  source = "../modules/k0s-aws"

  name             = "labs-dex"
  zone             = "mirantis.mart.red"
  controller_count = 3
  worker_count     = 3
  instance_type    = "t3.xlarge"
  vpc_id           = data.aws_vpc.default.id
  local_dir_path   = "${path.root}/.local/labs-dex"
  oidc_issuer_url  = "https://dex.apps.labs-dex.mirantis.mart.red"

  common_tags = var.common_tags
}
