/*****************************************************************************
Users

Handles users - creating, looking them up, authenticating. You can pretty much
gut this class and change it out if you want to integrate it with your own
authentication.

******************************************************************************/
// storage for the users
var users = require('./JSONStorage').load('./storage/users.json');
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

// the password rule to display to users
var passwordRules = "Passwords must be at least 6 characters long.";

// authenticates a user, returns the user object if the credentials are valid, null otherwise
exports.authenticate = function(username, password) {
    // conver the username to lower case and trim it, so we can use it as a key
    username = username.toLowerCase().trim();

    return false;
};

exports.createUser = function(userinfo) {
};

exports.deleteUser = function(username) {
};

// gets a user object - returns null if the user doesn't exist
exports.getUser = function(username) {
    // convert the username to lower case and trim it, so we can use it as a key
    username = username.toLowerCase().trim();
};

// changes a users password
// returns true/false
exports.changePassword = function(username, newPassword) {
};

// returns the password rules
exports.getPasswordRules = function() {
    return passwordRules;
};