# Setup command
kubectl oidc-login setup \
        --oidc-issuer-url=https://dex.apps.labs-dex.mirantis.mart.red \
        --oidc-client-id=kubernetes \
        --oidc-client-secret=M1BSMkZUWHYudlVHRGVOLi1ieGI0eiFpQjJxV252SGZHcTZDYyFWWgo= \
        --oidc-extra-scope=email \
        --oidc-extra-scope=groups \
        --oidc-extra-scope=profile

# Set credentials without setup (copied from setup command)
kubectl config set-credentials oidc \
	--exec-api-version=client.authentication.k8s.io/v1beta1 \
	--exec-command=kubectl \
	--exec-arg=oidc-login \
	--exec-arg=get-token \
	--exec-arg=--oidc-issuer-url=https://dex.apps.labs-dex.mirantis.mart.red \
	--exec-arg=--oidc-client-id=kubernetes \
	--exec-arg=--oidc-client-secret=M1BSMkZUWHYudlVHRGVOLi1ieGI0eiFpQjJxV252SGZHcTZDYyFWWgo= \
	--exec-arg=--oidc-extra-scope=email \
	--exec-arg=--oidc-extra-scope=groups \
	--exec-arg=--oidc-extra-scope=profile

# Run get-token subcommand to understand credential flow
kubectl oidc-login get-token \
	--oidc-issuer-url=https://dex.apps.labs-dex.mirantis.mart.red \
	--oidc-client-id=kubernetes \
	--oidc-client-secret=M1BSMkZUWHYudlVHRGVOLi1ieGI0eiFpQjJxV252SGZHcTZDYyFWWgo= \
	--oidc-extra-scope=email \
	--oidc-extra-scope=groups \
	--oidc-extra-scope=profile \
  -v 8

# Set credentials using oidc auth-provider
kubectl config set-credentials oidc \
        --auth-provider=oidc \
        --auth-provider-arg=idp-issuer-url=https://dex.apps.labs-dex.mirantis.mart.red \
        --auth-provider-arg=client-id=kubernetes \
        --auth-provider-arg=client-secret=M1BSMkZUWHYudlVHRGVOLi1ieGI0eiFpQjJxV252SGZHcTZDYyFWWgo=
