terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.51.1"
    }
  }
}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "swordfish"
  auth_url    = "http://172.31.7.154/identity"
}

data "openstack_compute_instance_v2" "test" {
  id = "48720bc4-66de-4c36-8ec4-4aef8c550e82"
}

output "test" {
  value = data.openstack_compute_instance_v2.test.name
}
