#!/bin/sh

# Get the domain, Cloudflare DNS token, Cloudflare account ID, and Cloudflare KV token from environment variables
domain=$DOMAIN
dns_token=$CF_DNS_TOKEN
account_id=$CF_ACCOUNT_ID
kv_token=$CF_KV_TOKEN
kv_namespace=$CF_KV_NAMESPACE
email=$EMAIL

# Create the Cloudflare.ini file with the DNS token
echo "dns_cloudflare_api_token = $dns_token" > /tmp/cloudflare.ini

# Generate a new certificate for the domain
if [ $CERTBOT_TEST_MODE = "true" ]
then
  certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /tmp/cloudflare.ini \
    --test-cert \
    -d $domain \
    -d *.$domain \
    --email $email \
    --agree-tos \
    --non-interactive
else
  certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /tmp/cloudflare.ini \
    -d $domain \
    -d *.$domain \
    --email $email \
    --agree-tos \
    --non-interactive
fi

# Check if the certificate was generated successfully
if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ] || [ ! -f /etc/letsencrypt/live/$domain/privkey.pem ]; then
    echo "Failed to generate certificate"
    exit 1
fi

# Upload the certificate to Cloudflare KV
ls /etc/letsencrypt/live/$domain/ 
echo ----------- THIS IS THE CERTIFICATE -------------
cat /etc/letsencrypt/live/$domain/fullchain.pem
echo -------------------------------------------------
full_cert_value=$(cat /etc/letsencrypt/live/$domain/fullchain.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
cert_value=$(cat /etc/letsencrypt/live/$domain/cert.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
key_value=$(cat /etc/letsencrypt/live/$domain/privkey.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
cert_date=$(date +"%Y%m%d")
payload='[{"key":"privkey.pem","value":"'"$key_value"'"},{"key":"cert.pem","value":"'"$cert_value"'"},{"key":"fullchain.pem","value":"'"$full_cert_value"'"},{"key":"_archive_'$cert_date'_privkey.pem","value":"'"$key_value"'"},{"key":"_archive_'$cert_date'_cert.pem","value":"'"$cert_value"'"},{"key":"_archive_'$cert_date'_fullchain.pem","value":"'"$full_cert_value"'"}]'

echo $payload

curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$account_id/storage/kv/namespaces/$kv_namespace/bulk" \
     -H "Authorization: Bearer $kv_token" \
     -H "Content-Type: application/json" \
     --data "$payload"