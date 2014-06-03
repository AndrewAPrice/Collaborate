/*****************************************************************************
Discussions

Backend for discussions and forums.

******************************************************************************/

var Database = require("./Database.js");

exports.initialize = function() {
};

exports.getRecentThreads = function(callback) {
    Database.getRecentDiscussionThreads(callback);
};

exports.getRecentPosts = function(callback) {
    Database.getRecentDiscussionPosts(callback);
};

exports.getDiscussionForums = function(callback) {
    Database.getDiscussionForums(callback);
};