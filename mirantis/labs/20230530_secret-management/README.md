# Secret Management

Watch the recording: TBD

### Event Description
While out-of-the-box Kubernetes provides rudimentary secret management, most teams need more sophisticated functionality like dynamic secrets and secret rotation.

HashiCorp’s Vault is a popular open source solution, providing best-in-class secret management capabilities. Better yet, the project’s new Kubernetes operator integrates Vault smoothly with Kubernetes clusters, so developers can consume secrets more easily. But setting up a production-grade implementation isn’t always easy.

In this Tech Talk, we’ll show you:
🔑 Why Vault is a good choice for cloud-agnostic secrets management
🔑 How to deploy a production-grade setup
🔑 Tips for establishing secure secrets management workflows

## Demo

I need to cleanup the demo deployment files first 🙈, before I will upload them here! Expect them till 1st of June, 2023 🤞

## Research

I really recommend to read the must-reads! They are a great resource to understand the bigger problem with Secret Management as a whole, as well as in combination with Kubernetes:

- **[MUST READ]** Plain Kubernetes Secrets are fine: https://www.macchaffee.com/blog/2022/k8s-secrets/
  - Reddit: https://www.reddit.com/r/kubernetes/comments/weo10u/plain_kubernetes_secrets_are_fine/
- **[MUST READ]** Under-documented Kubernetes Security Tips: https://www.macchaffee.com/blog/2022/k8s-under-documented-security-tips/
- How to securely create, edit and update your K8s secrets: https://www.kosli.com/blog/how-to-securely-create-edit-and-update-your-kubernetes-secrets/
- Deep Dive into Real-World Kubernetes Threats: https://research.nccgroup.com/2020/02/12/command-and-kubectl-talk-follow-up/
- Mounting secrets as files without deleting: https://www.patrickdap.com/post/mounting-secrets-configmaps-without-deleting/
  - Caution! Secrets will not get updated when using `subPath`: https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod
- Managing Kubernetes Secrets: https://blog.aquasec.com/managing-kubernetes-secrets
- Bad Pods: Kubernetes Pod Privilege Escalation: https://bishopfox.com/blog/kubernetes-pod-privilege-escalation
  - Unrelated, but very interesting 🤓

### Secret Management Integrations for Kubernetes

Kubernetes Integrations:
- HashiCorp Vault: https://developer.hashicorp.com/vault/docs/platform/k8s
- ArgoCD Vault Plugin: https://argocd-vault-plugin.readthedocs.io/en/stable/
- CSI Secret Store Driver: https://secrets-store-csi-driver.sigs.k8s.io/concepts.html#provider-for-the-secrets-store-csi-driver
- External Secret Operator: https://external-secrets.io/
- Sealed Secrets: https://github.com/bitnami-labs/sealed-secrets
- SOPS: https://github.com/mozilla/sops
- 
### Operating Vault and Vault Secrets Operator

- Kubernetes Reference Architecture for Vault: https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-reference-architecture
- Kubernetes integrations comparison (without Secrets Operator): https://developer.hashicorp.com/vault/docs/platform/k8s/injector-csi#comparison-chart
- Vault Secrets Operator: https://developer.hashicorp.com/vault/docs/platform/k8s/vso
