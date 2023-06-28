# Crossplane

Recording on Youtube: 
Slides: [Click here](slides.pdf)

### Event Description
In an increasingly multi-cloud world, managing and provisioning resources across cloud providers can be a complex task. Crossplane, an open-source infrastructure as code (IaC) project, transforms the multi-cloud landscape by enabling unified service provisioning and management.

In this Tech Talk, Martin Nirtl and David Murphy (Upbound) explore Crossplane's design and operation, demonstrating its ability to orchestrate cloud services seamlessly, irrespective of the provider. We'll explore how Crossplane…

- Enables developers to define and compose cloud services directly from Kubernetes, offering a universal control plane
- Can be effectively managed using Lens, the Kubernetes IDE, and used to create and handle OpenStack resources
- Empowers developers to model complex applications and infrastructure as manageable, declarative configurations

Join us to learn how you can leverage Crossplane in conjunction with Lens and OpenStack—to simplify cloud service management and foster a more efficient and scalable multi-cloud strategy

## Demo

For the demo, you will need a Kubernetes cluster (nothing specific, but preferably [k0s](https://k0sproject.io/) 😁) and an OpenStack deployment (please check the links section below). Make sure, the OpenStack API is reachable from the Kubernetes cluster.

Next, install Crossplane as described [here](https://docs.crossplane.io/latest/software/install/) or just apply the manifest file `demo/0-crossplane` (which is a helm-templated manifest of the official helm chart version 1.12.1 plus the `crossplane-system` namespace).

After that, you can go ahead and apply the manifests in the `demo` folder in their order. Before you apply them, make sure you understand what you are actually doing and maybe update the values like usernames and passwords in `demo/2-providerconfig.yaml`. If something does not work, please feel free to reach out to me!

## Links

In case you want to get started with Crossplane, I have put together the following list of links (mostly Crossplane docs):

- Install Crossplane: https://docs.crossplane.io/latest/software/install/
- Getting Started: https://docs.crossplane.io/latest/getting-started/
- How to create compositions: https://docs.crossplane.io/latest/concepts/composition/
- OpenStack
  - DevStack: https://docs.openstack.org/devstack/latest/
  - TryMOSK (Mirantis OpenStack on Kubernetes): https://www.mirantis.com/download/mirantis-cloud-native-platform/mirantis-openstack-for-kubernetes/