'use strict';

const http = require('http');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Your ARC Microservices ECS Blueprint is live.',
    poweredBy: 'SourceFuse ARC Blueprint',
    version: VERSION,
    request: { method: req.method, path: req.url },
    db: process.env.DB_HOST || null,
    redis: process.env.REDIS_HOST || null,
    sqs: process.env.SQS_QUEUE || null,
    timestamp: new Date().toISOString(),
  }, null, 2));
});

server.listen(PORT, () => console.log(`Sample app listening on :${PORT}`));
