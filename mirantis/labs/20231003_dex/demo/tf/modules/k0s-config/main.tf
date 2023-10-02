# TODO move towards template file: https://developer.hashicorp.com/terraform/language/functions/templatefile

locals {
  k0s_config = {
    version       = "1.27.1+k0s.0"
    dynamicConfig = true
    config = {
      apiVersion = "k0s.k0sproject.io/v1beta1"
      kind       = "Cluster"
      metadata = {
        name = var.name
      }
      spec = {
        api = {
          externalAddress = var.api_fqdn
          k0sApiPort      = 9443
          port            = 6443
          sans = [
            var.api_fqdn,
          ]
          extraArgs = {
            "feature-gates"       = "APISelfSubjectReview=true"
            "service-account-issuer"   = var.service_account_issuer_url
            "service-account-jwks-uri" = "${var.service_account_issuer_url}/openid/v1/jwks"
            "oidc-issuer-url"          = "https://dex.${var.apps_fqdn}"
            "oidc-client-id"           = "kubernetes"
            "oidc-username-claim"      = "email"
            "oidc-groups-claim"        = "groups"
            # "oidc-ca-file"             = "/etc/ssl/certs/openid-ca.pem"
          }
        }
        installConfig = {
          users = {
            etcdUser          = "etcd"
            kineUser          = "kube-apiserver"
            konnectivityUser  = "konnectivity-server"
            kubeAPIserverUser = "kube-apiserver"
            kubeSchedulerUser = "kube-scheduler"
          }
        }
        konnectivity = {
          adminPort = 8133
          agentPort = 8132
        }
        network = {
          kubeProxy = {
            disabled = false
            mode     = "iptables"
          }
          podCIDR     = "10.244.0.0/16"
          provider    = "custom"
          serviceCIDR = "10.96.0.0/12"
        }
        storage = {
          type = "etcd"
        }
        telemetry = {
          enabled = true
        }
        extensions = {
          helm = {
            repositories = [
              {
                name = "cilium"
                url  = "https://helm.cilium.io/"
              },
              {
                name = "ingress-nginx"
                url  = "https://kubernetes.github.io/ingress-nginx"
              },
              {
                name = "jetstack"
                url  = "https://charts.jetstack.io"
              }

            ]
            charts = [
              {
                order     = 1
                name      = "cilium"
                chartname = "cilium/cilium"
                namespace = "kube-system"
                version   = "1.13.2"
                values    = templatefile("${path.module}/helm/cilium.yaml.tpl", { name = var.name })
              },
              {
                order     = 2
                name      = "ingress-nginx"
                chartname = "ingress-nginx/ingress-nginx"
                namespace = "ingress-nginx"
                version   = "4.6.1"
                values    = templatefile("${path.module}/helm/ingress-nginx.yaml.tpl", {})
              },
              {
                order     = 2
                name      = "cert-manager"
                chartname = "jetstack/cert-manager"
                namespace = "cert-manager"
                version   = "v1.12.0"
                values    = templatefile("${path.module}/helm/cert-manager.yaml.tpl", {})
              }
            ]
          }
        }
      }
    }
  }

  k0sctl_config = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    metadata = {
      name = var.name
    }
    spec = {
      hosts = concat(
        [
          for controller_ip in var.controllers : {
            ssh = {
              address = controller_ip
              user    = var.user
              port    = 22
              keyPath = var.ssh_key_path
            }
            role = "controller+worker"
          }
        ],
        [
          for worker_ip in var.workers : {
            ssh = {
              address = worker_ip
              user    = var.user
              port    = 22
              keyPath = var.ssh_key_path
            }
            role = "worker"
          }
        ]
      )
      k0s = local.k0s_config
    }
  }
}
