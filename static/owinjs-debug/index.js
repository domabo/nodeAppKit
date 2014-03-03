var Browser = require('browser');
var Promise = require('promise');
var OwinJS = require('owinjs');
var router = require('owinjs-router');
var route = router();
var owinAppBuilder = OwinJS.AppBuilder;
var owinRazor = OwinJS.Razor;
var path = require('path');

var app = new owinAppBuilder;

app.use(route);

route.get('/', function(){
        filename = 'debug.js.html';
               pathbase = path.join(__dirname, "/views/");
               return  owinRazor.renderViewAsync(this, filename, pathbase);
               this.Response.writeHead(200, {"Content-Type" : "text/html"});
               this.Response.end("<h1>ERROR<h1>");
               
               return Promise.from(null);
      
        });

Browser.createOwinServer(app.build(),"debug").listen("hidden");
