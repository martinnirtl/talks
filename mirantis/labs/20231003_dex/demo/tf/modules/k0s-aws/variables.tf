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

variable "nodepools" {
  type = list(object({
    min_count   = number
    min_count   = number
    min_count   = number
    template_id = string
    lb_arn      = string
  }))
  default = []
}

variable "ssh_key_name" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "local_dir_path" {
  type = string
}

variable "ssh_key_path" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
