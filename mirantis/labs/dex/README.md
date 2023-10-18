# Kubernetes Authentication with Dex

Recording on Youtube: https://youtu.be/AaJUKPiLp7c
Slides: [Click here](slides.pdf)

### Event Description

Out of the box, Kubernetes provides only bare-bones support for authentication. Fortunately, open source projects like Dex can help organizations manage authentication at scale, providing single sign-on (SSO) functionality and much more.

On October 3, Mirantis’ Martin Nirtl will explain the fundamentals of Kubernetes authentication and walk you through how to use Dex with a live demo. Join the Tech Talk to learn:
- The pros and cons of available Kubernetes authentication mechanisms (with a focus on OIDC tokens)
- How to use Dex to implement SSO for Kubernetes
- Authorization challenges and best practices for overcoming them

## Demo

> TLDR More accessible demo guide (no AWS, no Azure) coming end of month! (Oct 2023)

After reviewing some feedback, I have decided to publish an easier, alternative demo guide than originally intended. The main reason for the change is that many watchers don't have an AWS nor Azure account.
However, if you want to go ahead with the stuff I have shown, please find all the files for infra provisioning and app manifests in the [demo](demo) folder. In case you face some issues or have general questions on k0s, Terraform, Kustomize or Dex, please feel free to reach out to me! My email is martin.nirtl@gmail.com

Expect the alternative guide by the end of the October, 2023. Apologize for the delay!

