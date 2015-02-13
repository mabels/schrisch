var os           = require('os');
var fs           = require('fs');
var path         = require('path');
var browserify   = require('browserify');
var watchify     = require('watchify');
var to5ify       = require('6to5ify');
var uglifyify    = require('uglifyify');

var tempdir   =  path.join(os.tmpdir(), 'schrisch/rwt-resources');
var basedir   =  path.join(__dirname, '.');
var targetdir =  path.join(__dirname, '../../../target/classes/babylon');
var babylon   =  './babylon.2.0.js';
var targetfile = './handler.js';

function copyBabylon() {
  fs.mkdirSync(targetdir);
  fs.createReadStream(path.join(basedir, babylon))
    .pipe(fs.createWriteStream(path.join(targetdir, babylon)));
  fs.createReadStream(path.join(basedir, babylon))
    .pipe(fs.createWriteStream(path.join(tempdir, babylon)));
}

function copyToTemp() {
  fs.createReadStream(path.join(targetdir, targetfile))
    .pipe(fs.createWriteStream(path.join(tempdir, targetfile)));
}

function mkdir(path, done) {
  fs.mkdir(path, function(err) {
    if (err && err.code !== 'EEXIST') {
      throw err;
    }

    done();
  });
}

function mkTargetdir(done) {
  var parts = targetdir.split('/');
  var progress = [];

  progress.push(parts.shift()); // push '', which represents the leading '/'

  var mkdirRecursive = function(path) {
    if (!parts.length) {
      return done();
    }

    progress.push(parts.shift());
    mkdir(progress.join('/'), mkdirRecursive);
  };
  mkdirRecursive();
}

var browserifyBundle;
function setup(opts) {
  opts = opts || {};
  browserifyBundle = browserify({
      basedir      : basedir,
      cache        : {},
      packageCache : {},
      fullPaths    : true,
      debug        : opts.debug || false
    })
    .transform(to5ify, {
      experimental : true,
      sourceMap    : opts.debug || false
    });
  if (!opts.debug) {
    browserifyBundle.transform(uglifyify, {global: true})
  }
  browserifyBundle.external(babylon);
  browserifyBundle.add('./main.js');
}

function build(done) {
  mkTargetdir(function() {
    var target = path.join(targetdir, targetfile);
    var wstream = fs.createWriteStream(target);

    browserifyBundle.bundle(function(err, data) {
      if (err) {
        console.error('-------------------- browserify error --------------------');
        console.error(err);
        console.error('----------------------------------------------------------');
        return;
      }

      if (typeof done === 'function') {
        done(err);
      }

    }).pipe(wstream);
  });
  copyBabylon();
}

function watch() {
  setup({debug: true});
  
  function onReady(err) {
    if (err) {
      console.log('faild built');
      console.log(err.toString());
    } else {
      copyToTemp();
      console.log('successfully built');
    }
  }
  
  watchify(browserifyBundle)
    .on('update', function(ids) {
      console.log('Updated component -> rebuild...');
      build(onReady);
    });
  
  build(onReady);
}

function dist() {
  setup();
  build();
}

if (process.argv[2] === '--watch') {
  watch();
} else {
  dist();
}

