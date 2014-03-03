var NativeModule = require('native_module');
module = require('module');
require = module._load;
var path = require('path');

process.cwd = function() { return process.workingDirectory; };

processbindingSave = process.binding;
var tty = function (){};
tty.TTY = {};
tty.isTTY = function() {return false;};

process.binding = function(string){
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

package = require('package.json');

//@ sourceURL=nodeappkit.js
//# sourceURL=nodeappkit.js

var owinDebug = require('../static/owinjs-debug');

module._extensions['.js'] = function(module, filename) {
    var file = path.basename(filename);
    
    var content = NativeModule.require('fs').readFileSync(filename, 'utf8') + '\r\n// # sourceURL=' + file;
    module._compile(stripBOM(content), filename);
};

function stripBOM(content) {
    // Remove byte order marker. This catches EF BB BF (the UTF-8 BOM)
    // because the buffer-to-string conversion in `fs.readFileSync()`
    // translates it to FEFF, the UTF-16 BOM.
    if (content.charCodeAt(0) === 0xFEFF) {
        content = content.slice(1);
    }
    return content;
}


