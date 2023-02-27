FROM certbot/dns-cloudflare:latest

RUN apk add --no-cache curl

# Set the entry point to a script that generates a new certificate and uploads it to Cloudflare KV
ENTRYPOINT ["/bin/sh", "-c", "/entrypoint.sh"]

# Copy the entrypoint script into the image
COPY entrypoint.sh /

# Make the script executable
RUN chmod +x /entrypoint.sh
