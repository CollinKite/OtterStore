const express = require('express');
const cors = require('cors');
const request = require('request');

const app = express();
const port = 3000;

app.use(cors());

app.get('/proxy/:url', (req, res) => {
  const url = decodeURIComponent(req.params.url);
  request.get(url).pipe(res);
});

app.listen(port, () => {
  console.log(`Proxy server running at http://localhost:${port}`);
});
