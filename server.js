#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');
const PORT = process.env.PORT || 3000;
const ROOT = process.cwd();
const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  let filePath = req.url === '/' ? '/index.html' : req.url;
  try {
    const fullPath = path.join(ROOT, 'public', filePath);
    if (fs.existsSync(fullPath) && fs.statSync(fullPath).isFile()) {
      const ext = filePath.split('.').pop();
      const types = {html:'text/html',js:'application/javascript',css:'text/css'};
      res.writeHead(200, {'Content-Type': types[ext] || 'text/plain'});
      fs.createReadStream(fullPath).pipe(res);
      return;
    }
  } catch {}
  res.writeHead(404);res.end('Not found');
});
server.listen(PORT, () => console.log(`[BEACON] Legal Rippler online at port ${PORT}`));
