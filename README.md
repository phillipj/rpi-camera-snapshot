# Raspberry Pi Camera Snapshots

A fork of the tutorial: http://thejackalofjavascript.com/rpi-live-streaming/

Simple Node.js server side application which communicates with the camera module
on a Raspberry Pi to capture photos.

## Get it started

```bash
$ npm install
$ npm start & node .
```

Then visit [http://localhost:8080](http://localhost:8080) in your favorite browser.

## Build for production

```bash
$ npm run build
```

## Run in production

```bash
$ npm install --production
$ node .
```

### Prerequisites

There is two requirements for the Raspberry Pi before being able to run this application:

1. [Node.js](https://nodejs.org)
2. [raspistill](https://www.raspberrypi.org/documentation/usage/camera/raspicam/raspistill.md)

### Local development

```bash
$ npm start
```

## Setup description

My current setup is pretty ad-hoc and whatever does the job.

### Transfer code to the Raspberry

```bash
$ git clone https://github.com/phillipj/rpi-camera-snapshot.git
# .. and later for updates:
$ git pull origin master
```

### Building Elm -> JavaScript

Since the current Elm compiler does not support being run on ARM, I gone with the pragmatic approach
and build Elm to JavaScript then commit the JavaScrpt bundle to git. Whenver I pull git for updates,
the frontend is already built and the Node.js server can be started immediately.

## License

MIT
