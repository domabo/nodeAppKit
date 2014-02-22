![nodeAppKit](https://raw.github.com/domabo/nodeAppKit/master/static/domaba/images/nodeAppKit.png)

## Overview

**nodeAppKit**, the lightweight Application UI for Desktop and Mobile Platforms, based on node.js but using  native javascript engines for small footprint and appstore compatability, and fully integrated with a modern HTML5 embedded browser to display the user interface.

Write once, deploy anywere (desktop, mobile: windows/RT/phone, OSX/iOS, linux, android, AND tradititional node.js server/client browser).    

Same application code on all these platforms without any conversion, compile switches etc.

Code in Javascript, with UI in HTML/CSS/javascript using your favorite template engine; Razor View Engine provided as preferred option.   Coffeescript, Less, or whatever you want all will work. 

Continue to write your applications in server / browser paradigm, but both run embedded in same process on the device with no networking required;  access native functions (GPS, gyroscope, printing etc.) as available in node.js or node-appkit extensions.

***EARLY PROOF OF CONCEPT ONLY***

Open source under Mozilla Public License.


Note: **nodeAppKit** is an implementation of the open source node.app **NodeLike** library, and most of the functionality would not be possible without it.  All we do is provide a host shell, hook up the webview to the javascript (nodelike) engine, and then provide the integration logic across both to make a seamless client-server.

### About

nodeAppKit is based on NodeLike, an open source project to implement a roughly Node.JS-compatible interface using JavaScriptCore.framework on iOS 7 and OS X Mavericks.

nodeAppKit is currently in an incomplete state, but does compile and runs basic node, connect, express and owin applications.

It is conceptually similar to node-webkit, but runs on mobile platforms and within appstores, and doesnt require changes to server side code when porting a web app (or vice versa). 

### Features

- Integrated HTML5 standards based browser (webkit/trident) based browser, but with no 60Mb webkit executable (Chromium CEF optional on Windows instead of built-in IE11/Trident)
- Integrated node.js runtime (re-uses javascript code from node.js project with light weight native libraries and built in javascript engines, apple javascriptcore or microsoft chakra, instead of Chromium V8)
- Loads quickly as both webview and javascript engine are native to operating system, not linked libraries
- Designed to be app store friendly (Apple, Microsoft, Android -- see roadmap)
- Requires no networking;  instead uses browser custom protocol to invoke HTTP-like requests to application in node.js or OWIN format with no ports opened
- Can use networking just like any other node app (libuv and http parser built in)
- Creates browser UI with no coding required
- Does not require special client side code;  just re-use your existing node.js express or connect applications, but run embedded within the app, not in a separate process or server
- Extensibility built in;  instead of hardcoding to undocumented node.js (req, res) interfaces, abstract web server as a standard implementation of an OWIN server (with translation back to node.js http/connect/express format for compatability)
	- OWIN = Open Web Interface for .NET and node.js, with simple and [well-documented](http://owin.org) interface
	- node.js is default provided pipeline, but other pipelines can be plugged in
- Uses package.json manifest for configuration of initial node script and initial browser home page;  extends node.js package format and same extensions as node-webkit where possible
- Built in static file server from embedded resource bundle (bypasses node pipeline for efficiency and used during application startup for splash pages;  files restricted to embedded resources for security and app store compatibility)
- Use Razor View Engine (javascript-based) for simple, dynamic views and separation of model, view, controllers
- Use websockets for interaction between UI and node.js app (for portability to cloud)
- Use Cocoa Pods for Objective-C dependencies
- Use NPM for node.js dependencies
- Write once, deploy exact same application code for UI ***AND*** application logic across Windows Store, OS X, Linux, Android, iOS, Windows Phone, Windows Desktop, etc.;  no compile switches, no separate repositories, etc. (just the node-appkit container that is platform specific);  use the same code in traditional node.js server for remote web browser clients 
- node.js application can serve both local UI and remote web clients and remote node-appkit clients simultaneously

### How to Use
Clone the project

`git clone https://github.com/domabo/node-appkit.git`

Get the Cocoa Pod dependencies

 `pod install`

Replace all the files in the /web directory with your node.js application;  even though it runs on the mac/pc/device, write it as if it is server side

`package.json` and `index.js` contain the configuration and bootstrap code;  use `npm install` from the /web folder to install any node dependencies

use `require('owin')` instead of or in addition to `require('http')`

Compile in Xcode and Archive/Validate/Distribute for local applications and iTunes App Store.

### Roadmap

Create pod spec

Port rest of domaba framework (closed .NET source) to open source javascript in this project

Once working on OS X, intent is to add Windows Store and Windows desktop applications, with source compatability of applications; after that we'll do Windows Phone 8

Tested on OS X only, requires simple porting to iOS;  underlying frameworks are already portable.

Finally we will port to Android

In other words this will be a universal UI kit, with all code in javascript / 

### Frameworks

#### [javascriptcore](http://asciiwwdc.com/2013/sessions/615)

#### [webkit](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DisplayWebContent/DisplayWebContent.html#//apple_ref/doc/uid/10000164i)

#### [node.js](http://nodejs.org)

#### [nodelike](https://github.com/node-app/Nodelike)
#### [OWIN/domaba framework](http://owin.org/) 
(owin based implementation for .NET and node.js)

### License

Open source under Mozilla Public License 2.0.


### Author

nodeAppKit container framework hand-coded by Domabo;  see frameworks above for respective authorship of the core components