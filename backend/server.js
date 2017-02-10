const express = require('express');
const http = require('http');
const fs = require('fs');
const path = require('path');
const RaspiCam = require('raspicam');

const app = express();
const camera = new RaspiCam({
  mode: 'photo',
  output: path.join(__dirname, '..', 'public', 'photos', 'photo-%d')
});

const isProduction = process.env.NODE_ENV === 'production';
const halfASecond = 1 * 500;
let proc;

function respondWithExamplePhoto(res) {
  setTimeout(() => {
    res.json({ src: 'photos/example.jpg' });
  }, halfASecond);
}

function capturePhoto() {
  return new Promise((resolve, reject) => {
    camera.start();

    camera.on('read', (err, timestamp, filename) => {
      if (err) {
        return reject(err);
      }

      resolve(filename);
    });

    camera.on('exit', () => {
      reject(new Error('Camera timed out :/'));
    });
  });
}

app.use('/', express.static(path.join(__dirname, '..', 'public')));

app.get('/photo', (req, res) => {
  if (isProduction) {
    capturePhoto().then((photoPath) => {
      res.json({ src: photoPath });
    }, (err) => {
      res.status(500).end(String(err));
    });
  } else {
    respondWithExamplePhoto(res);
  }
});

http.createServer(app).listen(3000, () => console.log('listening on *:3000'));
