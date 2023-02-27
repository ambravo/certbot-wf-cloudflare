const https = require('https');
const fs = require('fs');

const options = {
  // The following (updated) files are to be downloaded from certs.a0.gg.
  // The key and cert provided in this repo might be expired
  key: fs.readFileSync('_privkey.pem'), 
  cert: fs.readFileSync('_fullchain.pem') 
};

const server = https.createServer(options, (req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(3443, () => {
  console.log('Server listening on port https://local.a0.gg:3443');
});
