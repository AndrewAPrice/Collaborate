/*****************************************************************************
JSONStorage

Storage backend for saving/loading JSON files.  Things like groups, the pages,
etc. are stored as JSON objects on disk, and loaded into memory as objects.
When we modify the object we call .invalidate() which sets off a timer
(so we're not constantly writing to disk), and it saved when the timer expires.
You can also call .saveNow() to save the object to disk immediately.

******************************************************************************/
var fs = require('fs');

// Timeout to save: (seconds)
var saveTimer = 60;

// Load a JSON file
//  - path - the path to a JSON file, it must end in .json
// Returns a wrapper around the JSON file.
exports.load = function(path) {
    // some private variables:
    var saving = false; // are we currently saving?

    var timer = null; // timer for saving (starts when invalidated)

    // check if the file exists
    if(!fs.existsSync(path)) {
        // if it doesn't exist, let's write an empty json object so we have something to load
        fs.writeFileSync(path, "{}");
    }

    var storage = {};
    
    // the actual object we want to load and play with
    storage.object = require(path); // load the json object from disk
    
    // save this file to disk now
    storage.saveNow = function() {
        // stop any timer that may be running
        if(timer !== null) {
            clearTimeout(timer);
            timer = null;
        }

        // check if there's currently an async saving in progress
        if(saving) {
            // start another timer
            storage.invalidate();
            return;
        }

        saving = true;

        // convert the file to JSON format
        var json = JSON.stringify(storage.object);
        // save it to disk
        fs.writeFile(path, json, function(err) {
            saving = false; // done writing

            if(err)
                console.log("Error writing to " + path + ": " + err);
         });

    };

    // invalidate this file - this means it will be saved to disk after a certain amount of time
    storage.invalidate = function() {
        // check if another timer is running
        if(timer !== null) {
            // we don't want two timers running simultaneously for the same file - that would defeat
            // the whole purpose of timers - to group changes together!
            return;
        }

        // kick off a timer
        timer = setTimeout(storage.saveNow, saveTimer);
    };

    return storage;
};
