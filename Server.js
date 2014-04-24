/*****************************************************************************
Socket

Contains code for hosting the server and handling connections and messages.

******************************************************************************/
var app = require('express')();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

var Users = require('./Users.js');

// global settings for the Wiki (sent to the user)
exports.globalSettings = {
    // The wiki name (appears at the top of the wiki)
    wikiName: "Collaborate Test Wiki"
};

// global settings for the Wiki (not sent to the user)
exports.globalServerSettings = {
    // The port we should run the wiki on
    port: 81,
    // Can users access the Wiki without being logged in?
    publicAccess: true,
    // The address that emails coming from the Wiki come from
    emailAddress: "Collaborate <collaborate@test.com>",
    // The address that users can access this site at (for sending out links via email)
    siteAddress: "http://localhost:81/"
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
    server.listen(exports.globalServerSettings.port);
};

// called when a new socket connection is initialized
io.sockets.on('connection', function(socket) {
    // socket not logged in:
    socket.loggedIn = false;

    // socket id (the username trimmed and in lowercase)
    socket.userid = "";

    // socket username
    socket.username = "";

    // send global settings
    socket.emit('globalSettings', exports.globalSettings);

    // user requests global user settings
    socket.on('getGlobalUserSettings', function() {
        // send the global user settings
        socket.emit('globalUserSettings', Users.globalSettings);
    });

    // user requests login
    socket.on('login', function(data) {
        // check params were passed in
        if(typeof data !== 'object' || data.username === undefined || data.password === undefined) {
            socket.emit("loginResponse", { status: "nouser" });
            return;
        }

        // already logged in?
        if(socket.loggedIn == true)
            return;

        // authenticate
        Users.authenticate(data.username, data.password, function(response) {
            if(response.status === "success") {
                // save user info on socket if successful
                socket.loggedIn = true;
                socket.userid = response.id;
                socket.username = response.username;
            }

            socket.emit("loginResponse", response);
        });
    });

    // user requests to create a user
    socket.on('createUser', function(data) {
        // check params were passed in
        if(typeof data !== 'object' || data.username === undefined || data.password === undefined || data.email === undefined
            // cannot register if we are already logged in
            || socket.loggedIn == true) {
            socket.emit("createUserResponse", { status: "badusername" });
        }

        // create the user
        Users.createUser(data.username, data.password, data.email, function(response) {
            socket.emit("createUserResponse", response);
        });
    });

    // user requests to resend their verification email
    socket.on('resendVerificationEmail', function(data) {
        // check params were passed in
        if(typeof data !== 'object' || data.username === undefined || socket.loggedIn == true) {
            return;
        }

        Users.resendVerificationEmail(data.username);
    });

    // user tries to verify their email address
    socket.on('verifyEmail', function(data) {
        // check params were passed in
        if(typeof data !== 'object' || data.username === undefined || data.token === undefined || socket.loggedIn == true) {
            socket.emit("verifyEmailResponse", { status: "badcode" });
            return;
        }

        Users.verifyEmail(data.username, data.token, function(response) {
            socket.emit("verifyEmailResponse", response);
        });
    });

    // log the user out
    var logout = function() {
        // not logged in?
        if(socket.loggedIn == false) 
            return;
        socket.loggedIn = false;
        socket.userid = "";
        socket.username = "";
    };

    // user requests logout
    socket.on('logout', function() {
        logout();
    });

    // the user disconnects
    socket.on('disconnect', function() {
        logout();
    });
});