var mysql = require('mysql');

// modify this to access your database
var databaseSettings = {
    user: "root",
    password: "password!@",
    host: "localhost",
    port: 3306,
    database: "collaborate"
};

var pool = mysql.createPool(databaseSettings);

// callbacks are function(status, data)

// calls a block of SQL
// expectsStatus is a boolean representing if we should send read the @status variable after the call
var callSql = function(sql, expectsStatus, callback) {
    console.log("Calling " + sql);

    if(!expectsStatus) {
        // no @status variable, call as is
        pool.query(sql, function(err, rows) {
            if(err != null) {
                callback("badsql-call", null);
                console.log("SQL generated error: " + sql);
                console.log(err);
            } else
                callback('success', rows == null ? null : rows[0]);
        });
    } else {
        // grab a connection since this will be a sequential operation
        pool.getConnection(function(err, connection) {
            if(err != null)
                callback("noconnection", null);
            else {
                // perform the call
                connection.query(sql, function(err, rows) {
                    if(err != null) {
                        connection.release();
                        callback("badsql-call", null);
                        console.log("SQL generated error: " + sql);
                        console.log(err);
                    } else {
                        // grab the @status variable
                        connection.query("SELECT @status", function(err2, rows2) {
                            connection.release();
                            if(err2 != null)
                                callback("badsql-status", null);
                            else {
                                if(rows2 == null)
                                    callback("badsql-statusnull", null);
                                else if(rows2.length < 1)
                                    callback("badsql-statusnorows", null);
                                else {
                                    var status = rows2[0]["@status"];
                                    if(status === undefined)
                                        callback("badsql-statusnull", null);
                                    else
                                        // success, return status and results
                                        callback(status, rows[0]);
                                }
                            }
                        });
                    }
                });
            }
        });
    }
};

// users
exports.authenticateUser = function(username, password, callback) {
    callSql("CALL authenticate_user(" + pool.escape(username) + "," + pool.escape(password) + ",@status)",
        true, callback);
};

exports.getUserRealname = function(userid, callback) {
    callSql("CALL get_user_realname(" + pool.escape(userid) + ",@status)",
        true, callback);
};

exports.createUser = function(username, email, realname, callback) {
    callSql("CALL create_user(" + pool.escape(username) + "," + pool.escape(email) + "," + pool.escape(realname) + ",@status)",
        true, callback);
};

exports.resetUserToken = function(username, callback) {
    callSql("CALL reset_user_token(" + pool.escape(username) + ",@status)",
        true, callback);
};

exports.verifyUser = function(username, token, callback) {
    callSql("CALL verify_user(" + pool.escape(username) + "," + pool.escape(token) + ",@status)",
        true, callback);
};

// settings
exports.getSettings = function(callback) {
    callSql("CALL get_settings()", false, callback);
};

exports.setSetting = function(setting, value) {
    callSql("CALL set_setting(" + pool.escape(setting) + "," + pool.escape(value) + ")", false, function(status, result) {});
};