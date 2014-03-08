// MODULE DEPENDENCIES
module = require('module');
var path = require('path');

// NODE POLYFILLS AND ENHANCEMENTS UNIQUE TO NODEAPPKIT ENVIRONMENT

/**
 * Register process extensions
 *
 * process.cwd     return current working directory
 * process.binding  Polyfill missing Node libraries from NodeLike
 * process.warn     Map warnings to console log
 * process.versions Polyfill missing Node versions from NodeLike
 * process.nextTick  Re-Polyfill with simpler next Tick function
 * console.warn      Polyfill with console.log
 */

process.cwd = function cwd() { return  path.join(process.resourcePath, "/app") };
processbindingSave = process.binding;
var tty = function (){};
tty.TTY = {};
tty.isTTY = function() {return false;};

process.binding = function (string){
    if ((string == 'crypto') || (string=='zlib') || (string=='os') )
    {return {};}
    else {
        if (string == 'tty_wrap')
        { return tty; }
        else
        { return processbindingSave(string); }
    }
}
console.warn = console.log;

process.versions = { http_parser: '1.0', node: '0.10.4', v8: '3.14.5.8', ares: '1.9.0-DEV', uv: '0.10.3', zlib: '1.2.3', modules: '11', openssl: '1.0.1e' };

/**
 * Register javascript Module loader to add sourceURL to end of every file
 *
 */

module._extensions['.js'] = function nodeappkit_module_jsread(module, filename) {
    var file = path.basename(filename);
    
    var content = require('fs').readFileSync(filename, 'utf8') + '\r\n// # sourceURL=' + file;
    module._compile(stripBOM(content), filename);
};

function stripBOM(content) {
    if (content.charCodeAt(0) === 0xFEFF) {
        content = content.slice(1);
    }
    return content;
}

/**
 * NODEAPPKIT INITIALIZATION
 * Load Application package.json file, register nodeAppKit owin/js server, and load debug application
 */

package =  require('package.json');
process.owinJS = require('owinserver');
var owinDebug = require('../app-shared/owinjs-debug');

// # sourceURL=nodeappkit.js

