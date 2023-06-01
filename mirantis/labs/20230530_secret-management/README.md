# Secret Management

Recording on Youtube: https://youtu.be/LEno2fVuJ8U
Slides: [Click here](slides.pdf)

### Event Description
While out-of-the-box Kubernetes provides rudimentary secret management, most teams need more sophisticated functionality like dynamic secrets and secret rotation.

HashiCorp’s (HCP) Vault is a popular open source solution, providing best-in-class secret management capabilities. Better yet, the project’s new Kubernetes operator integrates Vault smoothly with Kubernetes clusters, so developers can consume secrets more easily. But setting up a production-grade implementation isn’t always easy.

In this Tech Talk, we’ll show you:
- Why Vault is a good choice for cloud-agnostic secrets management
- How to deploy a production-grade setup (from a theoretical standpoint, watch out for another session on HCP Vault where we do this live)
- Tips for establishing secure secrets management workflows
- How to use the new Vault Secrets Operator

## Demo

I kept the [demo](https://www.youtube.com/watch?v=LEno2fVuJ8U&t=1309s) and its setup intentionally simple to lower the entry level as much as possible. The demo setup itself was actually a mix of publicly available tutuorials from HashiCorp. If you don't know these tutorials and you appreciate Vault as much as I do, you should definitely [check them out](https://developer.hashicorp.com/vault/tutorials/kubernetes)!

If I could grow some interest and you are now looking for a guided tutorial, I recommend this official HCP tutorial using [Kind](https://kind.sigs.k8s.io/): [Static secrets with the Vault Secrets Operator on Kubernetes](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator#the-vault-secrets-operator)

If you are still curious what I did for my demo, I kind of combined the following two:
- Setting up HCP Vault with integrated storage (Raft): https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft
- Setting up Vault Secrets Operator and using static secrets: https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator

> Note: Some of the points in my demo (e.g. Kubernetes auth and secret name/path) are still very different to the tutorials' flows.

Apart from the setup, I have put all the custom resources and the demo app deployment (which is actually busybox doing nothing) with the different secret mount options into the [demo](demo) folder.

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
  - Related and very interesting 🤓

### Secret Management Integrations for Kubernetes

Kubernetes Integrations:
- HCP Vault: https://developer.hashicorp.com/vault/docs/platform/k8s
- ArgoCD Vault Plugin: https://argocd-vault-plugin.readthedocs.io/en/stable/
- CSI Secret Store Driver: https://secrets-store-csi-driver.sigs.k8s.io/concepts.html#provider-for-the-secrets-store-csi-driver
- External Secret Operator: https://external-secrets.io/
- Sealed Secrets: https://github.com/bitnami-labs/sealed-secrets
- SOPS: https://github.com/mozilla/sops

### Operating Vault and Vault Secrets Operator

- Kubernetes Reference Architecture for Vault: https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-reference-architecture
- Kubernetes integrations comparison: https://www.hashicorp.com/blog/kubernetes-vault-integration-via-sidecar-agent-injector-vs-csi-provider
- Vault Secrets Operator: https://developer.hashicorp.com/vault/docs/platform/k8s/vso
