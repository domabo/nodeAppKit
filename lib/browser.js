var events = require('events');
var util = require('util');
var stream = require('stream');
var cancellationTokenSource = require('cancellation');
var Promise = require('promise');
var owinJS = require('owinServer.js');

/* EXPORTS:
 * (server) createOwinServer(NodeFunc)
 * (server) createServer(func(req, res))
 * (server) createAppFuncServer(AppFunc)
 *
 * TYPEDEFS
 * NodeFunc = (void) function(OwinContext, NodeCallBack) {}
 * AppFunc = (Promise) function(OwinContext) {}
 * NodeCalBack = function(err, success) {}
 * server has Listen(url, title, width, height) function to create browser window and start server
 *
 */

var _listenFunction = function(url, title, x, y) {
    setTimeout(function()
               {
               if (!url)
               {
               url = global.package["node-baseurl"]+global.package.main;
               x=global.package.window.width;
               y=global.package.window.height;
               title=global.package.window.title;
               }
               
               process.createWindow(url, title, x, y);
               }, 1000);
}

exports.createOwinServer = function(nodeFunc) {
    var server =  owinJS.createOwinServer(nodeFunc);
    server.listen = _listenFunction;
    return server;
}

exports.createServer = function(connectApp) {
    return exports.createOwinServer(process.owinJS.owinConnect(connectApp));
};

exports.createAppFuncServer = function(appFunc) {
    return exports.createOwinServer(Promise.nodeify(appFunc));
}