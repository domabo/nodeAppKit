var Browser = require('browser');
var Promise = require('promise');
var OwinJS = require('OwinJS');
var owinAppBuilder = OwinJS.AppBuilder;
var owinRazor = OwinJS.Razor;

var app = new owinAppBuilder;
//@ sourceURL=filename.js
//# sourceURL=filename.js

var app2 = new owinAppBuilder;

app.use( function(next, callback){
        next(function(err, result){callback(err, result)});
        });

app.use(function(next, callback){
        var owin = this;
        path = 'index.js.html';
        
        var nextCallback = function(){
            next(function(err, result){callback(err, result)});
        };
        
        owinRazor.renderView(path, owin, nextCallback);
        });

app.use( function(next, callback){
        next(function(err, result){callback(err, result)});
        });

app2.use(function(next){
        var owin = this;
        path = 'index.js.html';
         return owinRazor.renderViewAsync(path, owin).then(function(){ return next()});
         });

Browser.createOwinServer(app2.build()).listen();


/*browser.createOwinServer(function (owin, callback) {
                         path = 'index.js.html';
                        Razor.renderView(path, owin, callback);
                  
                     }).listen(); */



//setTimeout(function() {console.log("hello world")},3000);