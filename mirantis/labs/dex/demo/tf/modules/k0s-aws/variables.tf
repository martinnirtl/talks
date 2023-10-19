variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "zone" {
  default  = ""
  nullable = true
}

variable "instance_type" {
  type = string
}

variable "controller_count" {
  default = 3
}

variable "worker_count" {
  default = 3
}

variable "oidc_issuer_url" {
  type = string
}

variable "local_dir_path" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
