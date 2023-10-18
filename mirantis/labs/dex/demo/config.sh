kubectl oidc-login setup \
        --oidc-issuer-url=https://dex.apps.labs-dex.mirantis.mart.red \
        --oidc-client-id=kubernetes \
        --oidc-client-secret=M1BSMkZUWHYudlVHRGVOLi1ieGI0eiFpQjJxV252SGZHcTZDYyFWWgo= \
        --oidc-extra-scope=email \
        --oidc-extra-scope=groups \
        --oidc-extra-scope=profile
