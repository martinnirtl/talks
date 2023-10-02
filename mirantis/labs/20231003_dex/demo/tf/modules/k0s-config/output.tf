output "k0s_config" {
  value = replace(yamlencode(local.k0s_config), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")
}

output "k0sctl_config" {
  value = replace(yamlencode(local.k0sctl_config), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")
}
