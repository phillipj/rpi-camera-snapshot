const express = require('express');
const http = require('http');
const fs = require('fs');
const path = require('path');

const app = express();

let proc;

app.use('/', express.static(path.join(__dirname, '..', 'public')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'index.html'));
});

http.createServer(app).listen(3000, () => console.log('listening on *:3000'));
