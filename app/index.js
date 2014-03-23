/**
 * An Owin Server
 *
 * @class OwinServer
 *
 * @constructor
 * @public
 */

global.Browser.createServer(function(){return null;}).listen();

// Replace above with below for example Static Server
/*var owinjs = require('owinjs');
var owinStatic = require('owinjs-static');

var app = new owinjs.app();

app.use(owinStatic('./', {sync:true}));

owinjs.createServer(app.build()).listen();

console.log('Server started');
*/
