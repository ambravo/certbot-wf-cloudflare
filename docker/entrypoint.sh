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

# Download the current fullchain cert and private key from the website
TEMP_DIR="/tmp/certbot_temp"
DOWNLOAD_URL_CHAIN="https://certs.$DOMAIN/download?key=_fullchain.pem"
DOWNLOAD_URL_PK="https://certs.$DOMAIN/download?key=_privkey.pem"
echo "Fullchain URL: $DOWNLOAD_URL_CHAIN"
echo "Private key URL: $DOWNLOAD_URL_PK"
mkdir -p $TEMP_DIR
if curl -o $TEMP_DIR/fullchain.pem $DOWNLOAD_URL_CHAIN && \
   [ -s $TEMP_DIR/fullchain.pem ] && \
   curl -o $TEMP_DIR/privkey.pem $DOWNLOAD_URL_PK && \
   [ -s $TEMP_DIR/privkey.pem ]; 
then
  echo "Successfully downloaded fullchain and private key"
  REFRESH_FLAG="--cert-path $TEMP_DIR/fullchain.pem --key-path $TEMP_DIR/privkey.pem "
else
  echo "Fullchain and/or private key not found"
  REFRESH_FLAG=""
fi

# Generate a new certificate for the domain
if [ $CERTBOT_TEST_MODE = "true" ]
then
  TEST_FLAG="--test-cert "
else
  TEST_FLAG=""
fi

certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /tmp/cloudflare.ini \
  -d $domain \
  -d *.$domain \
  --email $email \
  --agree-tos \
  --non-interactive \
  $REFRESH_FLAG \
  $TEST_FLAG

# Check if the certificate was generated successfully
if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ] || [ ! -f /etc/letsencrypt/live/$domain/privkey.pem ]; then
    echo "Failed to generate certificate"
    exit 1
fi

# Upload the certificate to Cloudflare KV
echo "File list:"
ls /etc/letsencrypt/live/$domain/ 

full_cert_value=$(cat /etc/letsencrypt/live/$domain/fullchain.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
cert_value=$(cat /etc/letsencrypt/live/$domain/cert.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
key_value=$(cat /etc/letsencrypt/live/$domain/privkey.pem | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')
cert_date=$(date +"%Y%m%d")
payload='[{"key":"_privkey.pem","value":"'"$key_value"'"},{"key":"_cert.pem","value":"'"$cert_value"'"},{"key":"_fullchain.pem","value":"'"$full_cert_value"'"},{"key":"archive_'$cert_date'_privkey.pem","value":"'"$key_value"'"},{"key":"archive_'$cert_date'_cert.pem","value":"'"$cert_value"'"},{"key":"archive_'$cert_date'_fullchain.pem","value":"'"$full_cert_value"'"}]'

curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$account_id/storage/kv/namespaces/$kv_namespace/bulk" \
     -H "Authorization: Bearer $kv_token" \
     -H "Content-Type: application/json" \
     --data "$payload"
echo "Done!"