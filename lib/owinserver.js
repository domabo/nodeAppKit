var events = require('events');
var util = require('util');
var stream = require('stream');
var cancellationTokenSource = require('cancellation');
var Buffer = require('buffer').Buffer;
//@ sourceURL=some-url-goes-here


/* EXPORTS:
 * (owinserver) createOwinServer(AppFunc)
 * (owinContext) createContext();
 * (void) invokeContext(owinContext);
 * (function(owinContext)) owinConnect(ConnectApp)
 *
 * TYPEDEFS
 * NodeFunc = (void) function(OwinContext, NodeCallBack) {}
 * NodeCalBack = function(err, success) {}
 *
 */

owinServer = function(){};
util.inherits(owinServer, events.EventEmitter);

exports = module.exports = new owinServer;

var server = owinServer.prototype;

exports._addServer = function (NodeFunc, appId) {
    if (NodeFunc) {
         exports.addListener('request-'+appId, NodeFunc);
       }
}

exports.createOwinServer = function(nodeFunc, appId) {
    if (!appId)
        appId = "default";
    exports._addServer(nodeFunc, appId);
    return exports;
}

exports.createContext = function() {
    
    owin =  {
      Request: {},
      Response: {},
      Server: {},
      NodeAppKit: {}
    };
    
    owin.Request.Headers = {};
    owin.Request.Method = "GET";
    owin.Request.Path = "";
    owin.Request.PathBase = "";
    owin.Request.Protocol = "HTTP/1.1";
    owin.Request.QueryString ="";
    owin.Request.Scheme = "http";
    
    // REQUEST STREAM
    var Readable = stream.Readable;
    
    function RequestStream() {
        this.data = "";
    }
    
    util.inherits(RequestStream, Readable);
    
    RequestStream.prototype.setData = function(str)
    {
        Readable.call(this, { highWaterMark: str.length});
        this.data = str;
    }
    
    RequestStream.prototype._read = function(size) {
        this.push(this.data);
        this.push(null);
     }
    
    owin.Request.Body = new RequestStream;
   
    // RESPONSE STREAM
    var Writable = stream.Writable;
    
    function ResponseStream() {
        Writable.call(this, {decodeStrings: false});
        this.bodyChunks = []
    }
    
    util.inherits(ResponseStream, Writable);
    
    ResponseStream.prototype._write = function(chunk, enc, next) {
        this.bodyChunks.push(chunk);
        next();
    }
    
    ResponseStream.prototype.getBody = function() {
        return this.bodyChunks.join('');
    }
 
    owin.Response.Body = new ResponseStream;
    
    //OTHER RESPONSE ELEMENTS
 
    var tokenSource = cancellationTokenSource();
    
    owin.Response.Headers = {};
    owin.Response.StatusCode = "200";
    owin.Response.ReasonPhrase = "OK";
    owin.Response.Protocol = owin.RequestProtocol;
    owin.callCancelled = tokenSource.token;
    owin.NodeAppKit.callCancelledSource = tokenSource;
    owin.Version = "1.0";
    
    owin.Response.writeHead = function(statusCode, headers)
    {
        owin.Response.StatusCode = statusCode;
        
        var keys = Object.keys(headers);
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            if (k) owin.Response.Headers[k] = headers[k];
        }
   }
    
    owin.Response.setHeader = function(key, value)
    {
       owin.Response.Headers[key] = value;
    }
    
    owin.Response.write = function(data)
    {
        owin.Response.Body.write(data);
    }
    
    owin.Response.end = function(data)
    {
        owin.Response.Body.end(data);
        owin.Response.setHeader("Content-Length", "-1");
    }
    
    return owin;
};

exports.invokeContext = function(owin, callBack) {
    var appId = owin.AppId;
    if (!appId)
        appId = "default";
    
    if (owin.Request.Scheme == "debug")
        appId= "debug";
    
    console.log(owin.Request.Path + " " + appId);
    
    owin.NodeAppKit.OnSendingHeaderListeners = [];
    
    owin.Server.OnSendingHeaders = function(callback, state) {
        owin.NodeAppKit.OnSendingHeaderListeners.push({callback: callback, state: state});
    }
    
    // TO DO: LOAD REQUEST COOKIES FROM CACHE
  
    //SCHEDULE ACTUAL WORK ASYNC
    process.nextTick(function() {
                            exports.emit('request-'+appId, owin, function(err, value)
                                              {
                                         
                                         console.log(owin.Request.Scheme + err);
                                              // Call On Sending Headers
                                              var listeners = owin.NodeAppKit.OnSendingHeaderListeners;
                                              for (var i = 0; i <  listeners.length; i++) {
                                              listeners.callback(listeners.state);
                                              }
                                              
                                              // TODO : SAVE RESPONSE COOKIES TO CACHE
                                              
                                              // Add to Headers
                                              owin.Response.Headers["Access-Control-Allow-Origin"]= "*";
                                              owin.Response.Body = owin.Response.Body.getBody();
                                              callBack(err, value);
                                              
                                          });

                     });
};

