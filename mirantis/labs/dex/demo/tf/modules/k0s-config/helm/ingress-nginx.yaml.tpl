controller:
  extraArgs:
    enable-ssl-passthrough: true
  metrics:
    enabled: true
  service:
    enabled: true
    type: NodePort
    nodePorts:
      http: 32080
      https: 32443
