/*****************************************************************************
Users

Handles users - creating, looking them up, authenticating. You can pretty much
gut this class and change it out if you want to integrate it with your own
authentication.

******************************************************************************/
// storage for the users
// var db = require('./Storage.js').db;
var bcrypt = require('bcrypt-nodejs');
var crypto = require('crypto');
var mail = require('nodemailer').mail;

var Server = require('./Server.js');

// var usersDb = db.get('users');
// usersDb.index('id', { unique: true});

var users = require('./JSONStorage.js').load('./storage/users.json');

// the salt used for encrypting passwords - changing this will break users' passwords!
// if you're using this in a production environment you may generate a unique salt
var salt = "$2a$10$RRfYftqvlOI/fDW1Q5U48u"; // generated with bcrypt.genSaltSync(10);

// these are some global settings
exports.globalSettings = {
    // Can users register through the site? If this is false Administrators must manually add new users.
    canRegister: true,
    // password requirements to display to the user
    passwordRequirements:  "Passwords must be at least 6 characters long.",
    // do we need to verify the user's email address?
    verifyEmail: true
};

// users.object contains all users the lowercase username is the key

// tests if a password is valid - returns true/false
var isValidPassword = function(password) {
    // you can put your own rules in here - like must include special characters, numbers, etc

    // for now, this is a simple test that your password must be at least 6 characters long
    if(password.length < 6)
        return false;

    // pasword must be valid
    return true;
};

// generates an email confirmation key, returns null if we don't use verification
var generateEmailVerificationCode = function(callback) {
    if(exports.globalSettings.verifyEmail == false) {
        callback(null);
        return;
    }

    crypto.randomBytes(4, function(ex, buf) {
        callback(buf.toString('hex').toLowerCase());
    });
};

// sends a configmration email
var sendVerificationEmail = function(username, email, token) {
    var message = "=="+Server.globalSettings.wikiName+"==\n";
    message += username + ", thank you for registering an account.\n";
    message += "When you log in you will be prompted to provide this verification code: " + token + "\n\n";
    message += Server.globalServerSettings.siteAddress + "\n";

    mail({from: Server.globalServerSettings.emailAddress,
         to: email,
         subject: "Verify your e-mail address - " + Server.globalSettings.wikiName,
         text: message
   });
};

// authenticates a user, returns the user object if the credentials are valid, null otherwise
exports.authenticate = function(username, password, callback) {
    // convert the username to lower case and trim it, so we can use it as a key
    var id = username.toLowerCase().trim();

    // check if the username is valid
    if(id.length === 0) {
        callback({ status: "nouser" });
        return;
    }

    // fetch user
    var user = users.object[id];
    if(user === undefined) {
        callback({ status: "nouser" });
        return;    
    }

    if(user.verify !== null && exports.globalSettings.verifyEmail) {
        // they need to verify their email address
        callback({ status: "verifyemail" });
        return;
    };

    // compare the password
    bcrypt.compare(password, user.password, function(error, result) {
        if(error || !result) {
            callback({status: "badpassword"});
            return;
        }

        // all is good
        callback({status: "success", id: id, username: user.username, uiMessages: user.uiMessages});
    });
};

// creates a new user
exports.createUser = function(username, password, email, callback) {
    if(username === undefined || password === undefined || email === undefined ||
        exports.globalSettings.canRegister == false) {
        callback({ status: "badusername" });
        return;
    }

    // test the username
    var id = username.toLowerCase().trim();
    if(id.length == 0) {
        callback({ status: "badusername" });
        return;
    }

    // test the password
    if(!isValidPassword(password)) {
        callback({ status: "badpassword" });
        return;
    }

    // test the email address
    email = email.trim();
    if(email.length == 0 || email.indexOf('@') == -1) {
        callback({ status: "bademail" });
        return;
    }

    // encrypt the password
    bcrypt.hash(password, salt, null, function(error, result) {
        if(error) {
            callback({status: "badpassword"});
            return;
        }

        password = result;

        // generate a random email verification token
        generateEmailVerificationCode(function(token) {
            // callbacks are done, check if the user already exists
            if(users.object[id] !== undefined) {
                callback({status: "userexists"});
                return;
            }

            // insert us
            users.object[id] = {
                id: id,
                username: username,
                password: password,
                email: email,
                verify: token,
                uiMessages: {}
            };
            users.invalidate();
            
            if(exports.globalSettings.verifyEmail == true) {
                sendVerificationEmail(username, email, token);
                callback({ status: "verifyemail" }); // send a verification email
            } else
                callback({ status: "success" }); // user is created!
        });
    });
};

// deletes a user
// must either be ourself, or an administrator
exports.deleteUser = function(username, callerid, callback) {
};

exports.resendVerificationEmail = function(username) {
    var id = username.toLowerCase().trim();

    // check if the username is valid
    if(id.length === 0) {
        return;
    }

    // fetch user
    var user = users.object[id];
    // the user does not exist
    if(user === undefined)
        return;

    if(user.verify !== null && exports.globalSettings.verifyEmail) {
        // they need to verify their email address
        sendVerificationEmail(user.username, user.email, user.verify);
    };
};

exports.verifyEmail = function(username, token, callback) {
    var id = username.toLowerCase().trim();

    // check if the username is valid
    if(id.length === 0) {
        callback({ status: "badcode" });
        return;
    }

    // fetch user
    var user = users.object[id];
    // the user does not exist
    if(user === undefined) {
        callback({ status: "badcode" });
        return;
    }
    
    if(user.verify !== null && exports.globalSettings.verifyEmail) {
        // they need to verify their email address
        // sendVerificationEmail(user.username, user.email, user.verify);
        if(user.verify !== token)
            callback({ status: "badcode" });
        else {
            // verified
            user.verify = null;
            users.invalidate();
            
            // the user validated their code
            callback({ status: "success" });
        }
    } else {
        // the user does not need to verify their email address
        callback({ status: "badcode" });
    }
};

// gets a user object - returns null if the user doesn't exist
exports.getUser = function(username) {
    // convert the username to lower case and trim it, so we can use it as a key
    username = username.toLowerCase().trim();
};

// changes a users password
exports.changePassword = function(username, newPassword, callback) {
};
