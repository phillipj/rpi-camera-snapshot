const express = require('express');
const http = require('http');
const fs = require('fs');
const path = require('path');
const RaspiCam = require('raspicam');

const app = express();
const photosDirectory = path.join(__dirname, '..', 'public', 'photos');
const camera = new RaspiCam({
  // general options
  mode: 'photo',
  output: path.join(photosDirectory, '_photo.jpg'),

  // photo options
  quality: 100,
  encoding: 'jpg',
  awb: 'auto', // auto white balance
  // max resolution
  width: 2592,
  height: 1944
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

      const isTemporaryFile = filename.includes('~');
      if (!isTemporaryFile) {
        resolve(filename);
      }
    });

    camera.on('exit', () => {
      reject(new Error('Camera timed out :/'));
    });
  });
}

function renamePhotoWithTimestamp(originalFilename) {
  const extension = path.extname(originalFilename);
  const originalFilepath = path.join(photosDirectory, originalFilename);
  const filenameWithTimestamp = Date.now() + extension;
  const pathWithTimestamp = path.join(photosDirectory, filenameWithTimestamp);

  return new Promise((resolve, reject) => {
    fs.rename(originalFilepath, pathWithTimestamp, (err) => {
      if (err) {
        return reject(err);
      }

      resolve(filenameWithTimestamp);
    });
  });
}

app.use('/', express.static(path.join(__dirname, '..', 'public')));

app.get('/photo', (req, res) => {
  if (isProduction) {
    capturePhoto()
      .then(renamePhotoWithTimestamp)
      .then((filename) => {
        const photoFileUrl = `photos/${filename}`
        res.json({ src: photoFileUrl });
      }, (err) => {
        res.status(500).end(String(err));
      });
  } else {
    respondWithExamplePhoto(res);
  }
});

http.createServer(app).listen(3000, () => console.log('listening on *:3000'));
