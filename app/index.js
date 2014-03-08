var Browser = require('browser');
var owinjs = require('owinjs');
var router = require('owinjs-router');
var static = require('owinjs-static');
var razor = require('owinjs-razor');
var route = router();
var owinRazor = owinjs.Razor;

var app = new owinjs.app;

//app.use(route);

route.get('/', function routeGetDefault(){
            console.log("GET: " +this.request.path);
            var owin = this;
            fileName = 'index.js.html';
         
          return  razor.renderViewAsync(this, fileName);
          });

app.use(static('./bootstrap'));

Browser.createOwinServer(app.build()).listen('node://localhost', 'bootstrap', 800, 600);

/*browser.createOwinServer(function (owin, callback) {
                         path = 'index.js.html';
                        Razor.renderView(path, owin, callback);
                  
                     }).listen(); */


