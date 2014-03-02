var Browser = require('browser');
var Promise = require('promise');
var OwinJS = require('owinjs');
var router = require('owinjs-router');
var route = router();
var owinAppBuilder = OwinJS.AppBuilder;
var owinRazor = OwinJS.Razor;

//@ sourceURL=filename.js
//# sourceURL=filename.js

var app = new owinAppBuilder;

app.use(route);

route.getdebug('/id/{id}', function(){
        console.log("DEBUG: " + this.Request.Path + " :: " + JSON.stringify(this.Model));
        var owin = this;
        path = 'debug.js.html';
        return  owinRazor.renderViewAsync(path, this);
        });

route.getdebug('/', function(){
            console.log("DEBUG2: " + this.Request.Path + " :: " + JSON.stringify(this.Model));
            var owin = this;
            path = 'debug.js.html';
            return  owinRazor.renderViewAsync(path, this);
            });


route.get('/', function(){
            console.log("GET: " +this.Request.Path);
            var owin = this;
            path = 'index.js.html';
            
          return  owinRazor.renderViewAsync(path, this);
          });


Browser.createOwinServer(app.build()).listen();

/*browser.createOwinServer(function (owin, callback) {
                         path = 'index.js.html';
                        Razor.renderView(path, owin, callback);
                  
                     }).listen(); */



//setTimeout(function() {console.log("hello world")},3000);