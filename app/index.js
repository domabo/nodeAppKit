var Browser = require('browser');
var owinjs = require('owinjs');
var router = require('owinjs-router');
var static = require('owinjs-static');
var razor = require('owinjs-razor');
var route = router();
var owinRazor = owinjs.Razor;
var http = require('http');
var Promise =require('promise');
var util = require('util');

var app = new owinjs.app;

var APPSELECTOR = 200;

if (APPSELECTOR ==100)
app.use( route);

route.get('/', function routeGetDefault(){
          console.log("GET: " +this.request.path);
          var owin = this;
          fileName = 'index.js.html';
          
          return  razor.renderViewAsync(this, fileName);
          });

if (APPSELECTOR ==200)
app.use(static('./bootstrap'));

app.use(function(next, callback){
        if (APPSELECTOR ==1)
        {
        this.response.writeHead(200, {"Content-Type": "text/plain"});
        this.response.end("Hello World\n");
        next(function(err, result){callback(err,result);});
        }
        else return next(callback);
        });

app.use(function(next){
        if (APPSELECTOR ==2)
        {
        this.response.writeHead(200, {"Content-Type": "text/plain"});
        this.response.end("Hello World 2\n");
        return next();
        }
        else return next();
        });


app.use(function(req, res, next){
        if (APPSELECTOR ==3)
        {
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.end("Hello World 3\n");
        next();
        }
        else
        next();
        });


app.use(function(err, req, res, next){
        if (APPSELECTOR ==4)
        {
        if (err)
        {
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.end("Error reported in connect4: " + JSON.stringify(err));
        } else
        {
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.end("Hello World 4\n");
        }
        }
        else next();
        });

app.use(function(req, res){
        if (APPSELECTOR ==5)
        {
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.end("Hello World 5\n");
        }
        })

http.createServer(app.buildHttp()).listen(8080);

var server1= "http://localhost:8080/";
var server2 = "node://localhost/";
Browser.createOwinServer(app.build()).listen(server1, 'bootstrap', 800, 600);

/*browser.createOwinServer(function (owin, callback) {
 path = 'index.js.html';
 Razor.renderView(path, owin, callback);
 
 }).listen(); */

console.log('Server started');