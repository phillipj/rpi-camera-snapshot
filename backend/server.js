const async = require('async');
const compression = require('compression');
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

function now() {
  return new Date().toISOString();
}

function respondWithExamplePhoto(res) {
  setTimeout(() => {
    res.json({
      src: 'photos/example.jpg',
      capturedTimestamp: now()
    });
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

function resolvePhotoCreatedTime(filename, cb) {
  const filepath = path.join(photosDirectory, filename);
  return fs.stat(filepath, (err, stats) => {
    if (err) {
      return cb(err);
    }

    cb(null, {
      filename,
      capturedTimestamp: stats.ctime.toISOString()
    });
  })
}

app.use(compression());
app.use('/', express.static(path.join(__dirname, '..', 'public')));

app.get('/photo', (req, res) => {
  if (isProduction) {
    capturePhoto()
      .then(renamePhotoWithTimestamp)
      .then((filename) => {
        const photoFileUrl = `photos/${filename}`
        res.json({
          src: photoFileUrl,
          capturedTimestamp: now()
         });
      }, (err) => {
        res.status(500).end(String(err));
      });
  } else {
    respondWithExamplePhoto(res);
  }
});

app.get('/historical-photos', (req, res) => {
  fs.readdir(photosDirectory, (err, files) => {
    if (err) {
      return res.status(500).end('Could not read photos directory');
    }

    async.map(files, resolvePhotoCreatedTime, (err, filesWithCapturedDate) => {
      if (err) {
        return res.status(500).end('Could not read created time of photos');
      }

      const photos = filesWithCapturedDate
                      .map(fileObj => ({
                        src: `photos/${fileObj.filename}`,
                        capturedTimestamp: fileObj.capturedTimestamp
                      }));

      res.json(photos);
    });
  });
});

http.createServer(app).listen(3000, () => console.log('listening on *:3000'));
