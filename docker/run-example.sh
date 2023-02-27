#!/bin/sh 

docker build -t a0_cert-generator-image .

docker run --rm \
    -e DOMAIN=a0.gg \
    -e CF_DNS_TOKEN=your-dns-token \
    -e CF_ACCOUNT_ID=your-account-id \
    -e CF_KV_TOKEN=your-kv-token \
    -e CF_KV_NAMESPACE=your-kv-namespace  \
    -e CERTBOT_TEST_MODE=true \
    -e EMAIL=your-email \
    a0_cert-generator-image