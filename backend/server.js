const express = require('express');
const http = require('http');
const fs = require('fs');
const path = require('path');

const app = express();
const halfASecond = 1 * 500;

let proc;

app.use('/', express.static(path.join(__dirname, '..', 'public')));

app.get('/photo', (req, res) => {
  setTimeout(() => {
    res.json({ src: 'photos/example.jpg' });
  }, halfASecond);
});

http.createServer(app).listen(3000, () => console.log('listening on *:3000'));
