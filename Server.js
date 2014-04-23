/*****************************************************************************
Socket

Contains code for hosting the server and handling connections and messages.

******************************************************************************/
var app = require('express')();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

var Users = require('./Users.js');

// global settings for the Wiki
var globalSettings = {
    // The wiki name (appears at the top of the wiki)
    wikiName: "Collaborate Test Wiki"
};

// global server settings for the Wiki
var globalServerSettings = {
    // The port we should run the wiki on
    port: 81,
    // Can users access the Wiki without being logged in?
    publicAccess: true
};

app.get('/', function(req, res) {
    // redirect to the wiki page
    res.redirect('/wiki/');
});

app.get(/\/wiki\/(.*)/, function(req, res) {
    res.sendfile('client/index.html');
});

app.get(/\/client\/(.*)/, function(req, res) {
    res.sendfile('client/' + req.params[0]);
});


// start the server
exports.initialize = function() {
    // start the server
    server.listen(globalServerSettings.port);
};

// called when a new socket connection is initialized
io.sockets.on('connection', function(socket) {
    // socket not logged in:
    socket.loggedIn = false;

    // socket username
    socket.username = "";

    // send global settings
    socket.emit('globalSettings', globalSettings);

    // user requests global user settings
    socket.on('getGlobalUserSettings', function() {
        // send the global user settings
        socket.emit('globalUserSettings', Users.globalSettings);
    });

    // user requests login
    socket.on('login', function(data) {
        if(typeof data !== 'object' || data.Username === undefined || data.Password === undefined) {
            socket.emit("loginResponse", { status: "nouser" });
            return;
        }

        var result = Users.authenticate(data.Username, data.Password);

        socket.emit("loginResponse", socket);
        return;
    });

    // user requests logout
    socket.on('logout', function() {
        socket.loggedIn = false;
    });

    // the user disconnects
    socket.on('disconnect', function() {
    });
});