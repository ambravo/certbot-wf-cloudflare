const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('_privkey.pem'), //You download this file from certs.a0.gg
  cert: fs.readFileSync('_fullchain.pem') //You download this file from certs.a0.gg
};

const server = https.createServer(options, (req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(3443, () => {
  console.log('Server listening on port 3443');
});
