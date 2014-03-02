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

route.get('/', function(){
            console.log("GET: " +this.Request.Path);
            var owin = this;
            fileName = 'index.js.html';
         
          return  owinRazor.renderViewAsync(this, fileName);
          });

Browser.createOwinServer(app.build()).listen();
vvv
/*browser.createOwinServer(function (owin, callback) {
                         path = 'index.js.html';
                        Razor.renderView(path, owin, callback);
                  
                     }).listen(); */

//setTimeout(function() {console.log("hello world")},3000);