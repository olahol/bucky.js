# bucky.js (0.1.0)

Easily enable S3 CORS uploading on elements. Supports drag&drop and
multiple file input.

## Example

You will need:

* S3 bucket with suitable CORS configuration.
* A way to generate valid POST policies for said bucket. Policies should
  include `success_action_status = 200` and probably `Content-Type` too.

```js
var fileInput = document.getElementById("fileInput");
var dropArea = document.getElementById("dropArea");
var upload = bucky("mybucket", fileInput, dropArea);

upload.start = function () {
  // Fired before requests
  console.log("Starting upload ...");
};

upload.policy = function (file, cb) {
  // Fill in policy for file, usually done by an ajax call.
  var policy = {
    key: file.name
    , AWSAccessKey: "..."
  };
  cb(policy);
};

upload.progress = function (loaded, total) {
  var progress = Math.round(100 * loaded / total, 0);
  console.log(progress + "%");
};

upload.fail = function (file, key) {
  console.log("Failed to upload " + file.name);
};

upload.done = function (file, key) {
  console.log(file.name + " => " + key);
};

upload.stop = function () {
  console.log("Upload done.");
};
```

## API

### instance = bucky(bucketName, elements...)

Creates a new bucky and enables uploading to `bucketName` on elements. If
an element is not `input file multiple` enable drag&drop.

* * *

### instance.start = function ()

Before uploading process has begun.

* * *

### instance.policy = function (file, callback(policy))

Before each file is uploaded. `policy` must be a javascript object.

* * *

### instance.progress = function (loaded, total)

Progress handler, `loaded` is the number of bytes uploaded, `total` is the
total number of bytes to upload.

* * *

### instance.fail = function (file, key)

If a file upload fails.

* * *

### instance.done = function (file, key)

When a file upload finishes.

* * *

### instance.stop = function (file, key)

After uploading process finishes.
