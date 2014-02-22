var owin = require('owin');
var Promise = require('promise');

nodeApp = function (request, response) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end("Hello World\n");
}

nodeFunc = function (owin, callback) {
    owin.response.writeHead(200, {"Content-Type": "text/plain"});
    owin.response.end("Hello World\n");
    callback(null);
}

appFunc = function (owin) {
    var myPromise = new Promise(function (resolve, reject) {
                                owin.response.writeHead(200, {"Content-Type": "text/plain"});
                                owin.response.end("Hello World\n");
                                resolve("OK");
                                });
    
    return myPromise;
}

// Start Server
//var server = owin.createServer(nodeApp);
var server = owin.createOwinServer(nodeFunc);
//var server = owin.createAppFuncServer(appFunc);
server.listen();
