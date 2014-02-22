var browser = require('browser');
var Promise = require('promise');

nodeApp = function (request, response) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end("Hello World\n");
}

nodeFunc = function (owin, callback) {
    owin.Response.writeHead(200, {"Content-Type": "text/plain"});
    owin.Response.end("Hello World\n");
    callback(null);
}

appFunc = function (owin) {
    var myPromise = new Promise(function (resolve, reject) {
                                owin.Response.writeHead(200, {"Content-Type": "text/plain"});
                                owin.Response.end("Hello World\n");
                                resolve("OK");
                                });
    
    return myPromise;
}

// Start Server
//var server = browser.createServer(nodeApp);
var server = browser.createOwinServer(nodeFunc);
//var server = browser.createAppFuncServer(appFunc);
server.listen();
