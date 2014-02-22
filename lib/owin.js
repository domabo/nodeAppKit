var events = require('events');
var util = require('util');
var stream = require('stream');
var cancellationTokenSource = require('cancellation');
var Promise = require('promise');
process.owin = {};

/* EXPORTS:
 * 
 * (owinserver) createOwinServer(AppFunc)
 * (function(owinContext)) owinConnect(ConnectApp)
 * (server) createServer(func(req, res))
 *
 * TYPEDEFS
 * NodeFunc = (void) function(OwinContext, NodeCallBack) {}
 * AppFunc = (Promise) function(OwinContext) {}
 * NodeCalBack = function(err, success) {}
 * ConnectApp = function(req, res) {}
 *
 * EXTENDS global.process:
 *
 * (owinContext) createContext();
 * (void) invokeContext(owinContext);
 *
 */

function _OwinNodeServer(NodeFunc) {
    if (!(this instanceof _OwinNodeServer)) return new _OwinNodeServer(NodeFunc);
    
    if (NodeFunc) {
        this.addListener('request', NodeFunc);
    }
}

util.inherits(_OwinNodeServer, events.EventEmitter);

_OwinNodeServer.prototype.listen = function(url, title, x, y) {
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

exports.createBrowser = function(url, title, x, y) {setTimeout(function()
                                                        {
                                                        if (!url)
                                                        {
                                                        url = global.package["node-baseurl"]+global.package.main;
                                                        x=global.package.window.width;
                                                        y=global.package.window.height;
                                                        title=global.package.window.title;
                                                        }
                                                        
                                                        process.createWindow(url, title, x, y);
                                                      }, 1000);}

exports.createOwinServer = function(nodeFunc) {
     process.owin.server =  new _OwinNodeServer(nodeFunc);
    return process.owin.server;
}


exports.owinConnect = function(connectApp) {
    
    return function(owinContext, nodeCallBack) {
        
        var self =  this;
        
        var url = owinContext["owin.RequestPathBase"] + owinContext["owin.RequestPath"] + owinContext["owin.RequestQueryString"];
        
        var req = {
            headers        :    owinContext["owin.RequestHeaders"],
            method         :    owinContext["owin.RequestMethod"],
            originalUrl    :    url,
            query          :    owinContext["owin.RequestQueryString"],
            url            :    url,
            params         :    {},
            session        :    {},
            cookies        :    {},
            body           :    {},
            files          :    {}
        };
        
        var res = {
            chunkedEncoding:    false,
            finished       :    false,
            output         :    [],
            outputEncodings:    [],
            sendDate       :    false,
            shouldkeepAlive:    false,
            useChunkedEncdoingByDefault
                           :    Boolean,
            viewCallbacks  :    [],
            writable       :     true,
            statusCode     :    -1,
            cookies        :    {},
            cookie         :    function (name, value, options) {
                                    this.cookies[name] = { value: value, options: options};
                                 },
            clearCookie    :    function (name) { delete this.cookies[name]; },
            status         :    function (code) { this.statusCode = code; return this;}
        }
        
        var protocol = owinContext["owin.RequestProtocol"];
        req.httpVersion = protocol.split("/")[1];
        var httpVersionSplit = req.httpVersion.split(".");
        req.httpVersionMajor = httpVersionSplit[0];
        req.httpVersionMinor = httpVersionSplit[1];
        
        res.writeHead = function(statusCode, headers)
        {
            owinContext["owin.ResponseStatusCode"] = statusCode;
            owinContext["owin.ResponseHeaders"]= headers;
        }
        
        res.setHeader = function(key, value)
        {
            owinContext["owin.ResponseHeaders"][key]=value;
        }
        
        res.end = function(data)
        {
            owinContext["owin.ResponseBody"] = data;
            owinContext["owin.ResponseHeaders"]["Content-Length"]="-1";
        }
        
        req.res = res;
        res.req = req;
        
        connectApp(req, res);
        
        nodeCallBack(null);
    }
};

exports.createServer = function(connectApp) {
    return exports.createOwinServer(exports.owinConnect(connectApp));
};

exports.createAppFuncServer = function(appFunc) {
    return exports.createOwinServer(Promise.nodeify(appFunc));
}

exports.use = function(appFunc, next) {
    return exports.createOwinServer().then(next);
};


process.owin.createContext = function() {
    owin =  {};
    owin["owin.RequestHeaders"] = {};
    owin["owin.RequestMethod"] = "GET";
    owin["owin.RequestPath"] = "";
    owin["owin.RequestPathBase"] = "";
    owin["owin.RequestProtocol"] = "HTTP/1.1";
    owin["owin.RequestQueryString"] ="";
    owin["owin.RequestScheme"] = "http";
    
    var Writable = stream.Writable;
    
    function responseStream(options) {
        Writable.call(this, options);
    }
    
    util.inherits(responseStream, Writable);
    
    responseStream.prototype._write = function (chunk, enc, cb) {
        owin["owin.ResponseBodyChunk"] = chunk;
        
        cb();
    }
    
    var tokenSource = cancellationTokenSource();
    
    owin["owin.ResponseBody"] = responseStream;
    owin["owin.ResponseHeaders"] = {};
    owin["owin.ResponseStatusCode"] = "200";
    owin["owin.ResponseReasonPhrase"] = "OK";
    owin["owin.ResponseProtocol"] = owin.RequestProtocol;
    owin["owin.callCancelled"] = tokenSource.token;
    owin["nodeAppKit.callCancelledSource"] = tokenSource;
    owin["owin.Version"] = "1.0";
    
    owin.response = {};
    
    owin.response.writeHead = function(statusCode, headers)
    {
        owin["owin.ResponseStatusCode"] = statusCode;
        owin["owin.ResponseHeaders"]= headers;
    }
    
    owin.response.setHeader = function(key, value)
    {
        owin["owin.ResponseHeaders"][key]=value;
    }
    
    owin.response.end = function(data)
    {
        owin["owin.ResponseBody"] = data;
        owin["owin.ResponseHeaders"]["Content-Length"]="-1";
    }
    
    return owin;
};

process.owin.invokeContext = function(owinContext, callBack) {
    owinContext["nodeAppKit.OnSendingHeaderListeners"] = [];
    
    owinContext["server.OnSendingHeaders"] = function(callback, state) {
        owinContext["nodeAppKit.OnSendingHeaderListeners"].push({callback: callback, state: state});
    }
    
    // TO DO: LOAD REQUEST COOKIES FROM CACHE
    
    //SCHEDULE ACTUAL WORK ASYNC
    process.nextTick(function() {
    process.owin.server.emit('request', owinContext, function(err, value)
                             {
                            
                             // Call On Sending Headers
                             var listeners = owinContext["nodeAppKit.OnSendingHeaderListeners"];
                             for (var i = 0; i <  listeners.length; i++) {
                             listeners.callback(listeners.state);
                             }
                             
                             // TODO : SAVE RESPONSE COOKIES TO CACHE
                             
                             // Add to Headers
                             owinContext["owin.ResponseHeaders"]["Access-Control-Allow-Origin"]= "*";
                             
                             callBack(err, value);
                             
                             });
               });
    
};