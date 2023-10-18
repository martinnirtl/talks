variable "aws_region" {
  default = "eu-central-1"
  type    = string
}

variable "instance_type" {
  default = "t3.xlarge"
}

variable "vpc_id" {
  default = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

# variable "enable_cilium" {
#   default = false
# }
