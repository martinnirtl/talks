variable "name" {
  type = string
}

variable "api_fqdn" {
  type = string
}

variable "controllers" {
  type = list(string)
}

variable "workers" {
  type = list(string)
}

variable "ssh_key_path" {
  type = string
}

variable "user" {
  type    = string
  default = "ubuntu"
}

variable "oidc_issuer_url" {
  type = string
}

# variable "service_account_issuer_url" {
#   type = string
# }
