//var server = require('server');
//server.start();

var owin = require('owin');

nodeApp = function (request, response) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end("Hello World\n");
}

//var connect = require('connect');
var express = require('express'),
expressApp = express();

expressApp.get('/', function(req, res){
        res.send('Hello World Express');
        });


// Start Server
var server = owin.createServer(expressApp);
server.listen();

// is equivalent to:
/*
var server = owin.createOwinServer(owin.owinConnect(connectApp));
server.listen();
*/

// is equivalent to:
/*
 var appFunc = owin.OwinConnect(owin.owinConnect(connectApp));
 var app = owin.AppBuilder();
 app.use(appFunc);
 app.listen();   // build, create server, listen
 */

// is equivalent to:
/*
 var appFunc = owin.OwinConnect(owin.owinConnect(connectApp));
 var app = owin.AppBuilder();
 app.use(appFunc);
 var middleware = app.build();
 var server = owin.createOwinServer(middleware);
 server.listen();
 */

