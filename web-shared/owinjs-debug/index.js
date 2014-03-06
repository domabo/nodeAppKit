var Browser = require('browser');
var Promise = require('promise');
var path = require('path');

var app = function(owin, callback){
    var e = process.debugException();
    var fileName = e.locals['__filename'];
    var lines = e.source.split("\n");
    
     var newSource = '<pre id="preview" style="font-family: monospace; tab-size: 3; -moz-tab-size: 3; -o-tab-size: 3; -webkit-tab-size: 3;"><ol>';
    
    for(var i=0; i<lines.length; i++)
	{
         newSource += "<li>" + lines[i] + "</li>";
 	}
    newSource += "</ol></pre>";
    
    var message = [];
    message.push("-------------------------");
    message.push("Exception: " + e.exception);
    message.push("Description: " + e.description);
    message.push("Filename: " +fileName);
    message.push("    lineNumber: " + e.lineNumber);
    message.push("sourceLine: " + e.sourceLine + "");
    //      message.push("Locals");
    //       e.locals.forEach(function(entry) {message.push(" " + entry);});
    message.push("Call Stack");
    e.callStack.forEach(function(entry) {message.push("  " + entry);});
    console.log(message.join("\r"));
     owin.response.writeHead(200, {"Content-Type" : "text/html"});
     owin.response.write("<head></head>");
     owin.response.write("<body>");
     owin.response.write(message.join("<br>"));
     owin.response.write(newSource);
     owin.response.end("</body>");
    
    callback(null);
          }

Browser.createOwinServer(app,"debug").listen("hidden");
