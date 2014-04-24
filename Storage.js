/*****************************************************************************
Storage

Handles initialization of the MongoDB.

******************************************************************************/

var MongoClient = require('mongodb').MongoClient;

// global storage settings
exports.globalSettings = {
    // the address of the mongoDB server
    databaseAddress: 'localhost:27017/Collaborate'
};

// the mongo DB object we can use from anywhere
exports.db = require('monk')(exports.globalSettings.databaseAddress);