// var JSONStorage = require('./JSONStorage');
// var s = JSONStorage.load('./storage/users.json');

var server = require('./Server.js');
var JSONStorage = require('./JSONStorage.js');

server.initialize();

process.on('SIGINT', function () {
    JSONStorage.flush();
    process.exit(0);
});