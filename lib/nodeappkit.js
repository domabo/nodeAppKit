module = require('module');
require = module._load;
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
process.versions = { http_parser: '1.0',node: '0.10.4',v8: '3.14.5.8',ares: '1.9.0-DEV',uv: '0.10.3',zlib: '1.2.3',modules: '11',openssl: '1.0.1e' };

package = require('package.json');