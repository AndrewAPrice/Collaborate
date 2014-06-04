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
var Database = require('./Database.js');

// var usersDb = db.get('users');
// usersDb.index('id', { unique: true});

// var users = require('./JSONStorage.js').load('./storage/users.json');

// the salt used for encrypting passwords - changing this will break users' passwords!
// if you're using this in a production environment you may generate a unique salt
var salt = "$2a$10$RRfYftqvlOI/fDW1Q5U48u"; // generated with bcrypt.genSaltSync(10);

// these are some global settings
exports.globalSettings = {
    // Can users register through the site? If this is false Administrators must manually add new users.
    canRegister: true,
    // password requirements to display to the user
    passwordRequirements:  "Passwords must be at least 6 characters long."
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
/*var generateEmailVerificationCode = function(callback) {
    if(exports.globalSettings.verifyEmail == false) {
        callback(null);
        return;
    }

    crypto.randomBytes(4, function(ex, buf) {
        callback(buf.toString('hex').toLowerCase());
    });
};*/

// sends a configmration email
var sendVerificationEmail = function(realname, username, email, token) {
    var message = "=="+Server.globalSettings.communityName+"==\n";
    message += realname + ", thank you for registering an account. Your username is: " + username + "\n";
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
    Database.authenticateUser(username, password, function(status, rows) {
        if(status !== "success")
            callback({status: status}, null);
        else {
            var userid = rows[0]["id"];
            // todo, get messages
            Database.getUserLoginInformation(userid, function(status, rows) {
                if(status !== "success")
                    callback({status: status});
                else
                    callback({status: status,
                        userid: userid,
                        realname: rows[0].realname,
                        forumAdmin: rows[0].forum_admin !== null ? rows[0].forum_admin.readUInt8(0) == 1 :null,
                        forumModerator: rows[0].forum_moderator !== null ?  rows[0].forum_moderator.readUInt8(0) == 1 : null});
            });
        }
    });

    /*
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
    });*/
};

// creates a new user
exports.createUser = function(username, realname, email, callback) {
    if(username === undefined || realname === undefined || email === undefined ||
        exports.globalSettings.canRegister == false) {
        callback({ status: "badusername" });
        return;
    }

    // test the username
    username = username.toLowerCase().trim();
    if(username.length == 0) {
        callback({ status: "badusername" });
        return;
    }

    // test the realname
    realname = realname.trim();
    if(realname.length == 0) {
        callback({ status: "badrealname" });
        return;
    }

    // test the email address
    email = email.trim();
    if(email.length == 0 || email.indexOf('@') == -1) {
        callback({ status: "bademail" });
        return;
    }

    // create the user on the database
    Database.createUser(username, email, realname, function(status, result) {
        if(status !== "success")
            callback({ status: "badusername" });
        else {
            var token = result[0].token;
            sendVerificationEmail(realname, username, email, token);
            callback({ status: "verifyemail" }); // send a verification email
        }
    });
};

exports.resendVerificationEmail = function(username) {
    username = username.toLowerCase().trim();

    // check if the username is valid
    if(username.length === 0) {
        return;
    }
    
    // generate them a new token and get the necessary fields to send them a new vertification email
    Database.resetUserToken(username, function(status, results) {
        if(status !== "success")
            return;
        
        sendVerificationEmail(results[0].realname, results[0].username, results[0].email, results[0].token);
    });
};

exports.verifyEmail = function(username, token, callback) {
    username = username.toLowerCase().trim();

    // check if the username is valid
    if(username.length === 0) {
        callback({ status: "badcode" });
        return;
    }

    token = token.trim();

    Database.verifyUser(username, token | 0, function(status, result) {
        if(status !== "success")
            callback({ status: status });
        else // send the user their new password
            callback({ status: "success", password: result[0].password });
    });
};

// gets a user object - returns null if the user doesn't exist
exports.getUser = function(username) {
    // convert the username to lower case and trim it, so we can use it as a key
    username = username.toLowerCase().trim();
};

// changes a users password
exports.changePassword = function(username, newPassword, callback) {
};
