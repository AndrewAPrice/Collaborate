var Database = require('./Database.js');

var settings = {};

exports.initialize = function(callback) {
    Database.getSettings(function(status, result) {
        if(status !== "success")
            console.log("Could not get settings. Database.getSettings returned status '" + status + "'.");
        else {
            for(var i = 0; i < result.length; i++) {
                settings[result[i].name] = result[i].value;
            }

            callback();
        }
    });
};

exports.getSetting = function(name) {
    return settings[name];
};

exports.setSettings = function(name, value) {
    settings[name] = value;
    Database.setSetting(name, value);
};