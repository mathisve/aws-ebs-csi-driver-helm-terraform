#!/bin/bash
# this script retrieves the thumbprint of our OIDC thumbprint provider in order to add it as an identity provider in AWS

THUMBPRINT=$(echo | openssl s_client -connect oidc.eks.$1.amazonaws.com:443 2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON