# About local.a0.gg and HTTPS

The subdomain ```local.a0.gg``` is configured to resolve to your local machine's IP address (127.0.0.1). The trick then, is that it is possible to generate certificates for this domain name using ["Let's encrypt"](https://letsencrypt.org/).

```
; <<>> DiG 9.10.6 <<>> local.a0.gg

;; ANSWER SECTION:
local.a0.gg.		300	IN	A	127.0.0.1
```

 :exclamation: Just to be clear, this **does not** exposes your app to the internet. Rather, you are leveraging Cloudflare's domain name server to handle the DNS resolution, instead of using your local host table.

## Step 1: Download Key and Certificates

To create a HTTPS connection, you will need a key and a certificate. You can download these from https://certs.a0.gg. Keep in mind that these certificates do not last for more than 3 months, but there is an automated process that refresh the key and certificates each month.

## Step 2: Configure Your App

To run your app using the URL https://local.a0.gg, you will need to configure it to use the key and certificate files you downloaded.

The process for configuring your app will depend on the tech stack you're using. Check the sample node app provided

```js
const https = require('https');
const fs = require('fs');

const options = {
  // The following (updated) files are to be downloaded from certs.a0.gg.
  // The key and cert provided in this repo might be expired
  key: fs.readFileSync('_privkey.pem'), // https://certs.a0.gg/download?key=_privkey.pem
  cert: fs.readFileSync('_fullchain.pem') // https://certs.a0.gg/download?key=_fullchain.pem
};

const server = https.createServer(options, (req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(3443, () => {
  console.log('Server listening on https://local.a0.gg:3443');
});
```

## About this repo

This repo contains:
- The docker image used by a Github action that creates and refresh the certificates
- A sample https app that uses
- A Cloudflare worker code that hosts the updated cerficates using KVs