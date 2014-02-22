var events = require('events');
var util = require('util');
var stream = require('stream');
var cancellationTokenSource = require('cancellation');
var Buffer = require('buffer').Buffer;

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

function _OwinNodeServer(NodeFunc) {
    if (!(this instanceof _OwinNodeServer)) return new _OwinNodeServer(NodeFunc);
    
    if (NodeFunc) {
        this.addListener('request', NodeFunc);
    }
}

// Currently single server but eventually could support array
exports._server = null;

util.inherits(_OwinNodeServer, events.EventEmitter);

exports.createOwinServer = function(nodeFunc) {
    exports._server =  new _OwinNodeServer(nodeFunc);
    return exports._server;
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
    
    owin.NodeAppKit.OnSendingHeaderListeners = [];
    
    owin.Server.OnSendingHeaders = function(callback, state) {
        owin.NodeAppKit.OnSendingHeaderListeners.push({callback: callback, state: state});
    }
    
    // TO DO: LOAD REQUEST COOKIES FROM CACHE
    
    //SCHEDULE ACTUAL WORK ASYNC
    process.nextTick(function() {
                     exports._server.emit('request', owin, function(err, value)
                                              {
                                              
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

exports.owinConnect = function(connectApp) {
    
    return function(owin, nodeCallBack) {
        
        var self =  this;
        
        var url = owin.Request.PathBase + owin.Request.Path + owin.Request.QueryString;
        
        var req = {
            headers        :   owin.Request.Headers,
            method         :   owin.Request.Method,
            originalUrl    :    url,
            query          :   owin.Request.QueryString,
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
        
        var protocol = owin.Request.Protocol;
        req.httpVersion = protocol.split("/")[1];
        var httpVersionSplit = req.httpVersion.split(".");
        req.httpVersionMajor = httpVersionSplit[0];
        req.httpVersionMinor = httpVersionSplit[1];
        
        res.writeHead = function(statusCode, headers)
        {
            owin.Response.writeHead(statusCode, headers);
        }
        
        res.setHeader = function(key, value)
        {
            owin.Response.setHeader(key, value);
        }
        
        res.write = function(data)
        {
            owin.Response.write(data);
        }
        
        res.end = function(data)
        {
            owin.Response.end(data);
        }
        
        req.res = res;
        res.req = req;
        
        connectApp(req, res);
        
        nodeCallBack(null);
    }
};

