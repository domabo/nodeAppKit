![nodeAppKit](https://raw.github.com/OwinJS/nodeAppKit/master/app-shared/owinjs-splash/images/nodeAppKit.png)

## Overview: A Native Web Application Kit

**nodeAppKit**, the lean and mean developers kit for node.js-based desktop and mobile client applications;  well, it's based on core node.js source, but instead of using a separate embedded V8 engine or blink chromium renderer, nodeAppKit just uses the built in (native) javascript and html5 engines of the host operating system.   

Most modern operatings systems (OSX 10.9+, Windows 8.1+, modern Linux distributions, ioS 5+, ANDROID) now contain a high performance HTML5 rendering and javascript engines, often based on the same open source WebKit origin of Blink and V8.   In the past, version disparity made a framework like nodeAppKit impractic, but now it makes for very lean, fast loading modern apps, that are app-store compatible out of the box.

Write once, deploy anywhere: desktop, mobile: windows/RT/phone, OSX/iOS, linux, android, **AND tradititional node.js server/client browser**, all with the same code.  You no longer need to maintain separate server and client versions of modules, or package some with Browserify/Bower/Component.io and some with NPM.

Same application code on all these platforms without any conversion, compile switches etc.

Code in Javascript, with UI in HTML/CSS/javascript using your favorite template engine; Razor (JS) View Engine provided as preferred option, but we also enable space-pen as used by GitHub atom.   Coffeescript, Less, or whatever you want all will work. 

Continue to write your applications in server / browser paradigm, but both run embedded in same process on the device with no networking required;  access native functions (GPS, gyroscope, printing etc.) as available using a standards-based future proofed interface (OWIN/JS).

***EARLY PROOF OF CONCEPT ONLY***

Open source under Mozilla Public License.


Note: **nodeAppKit** is an implementation of the open source node.app **NodeLike** library, and most of the functionality would not be possible without it.  

All we do is provide a host shell, hook up the webview to the javascript (nodelike) engine, and then provide the integration logic across both to make a seamless client-server.  We are however quite proud of the OWIN/JS implementation which differentiates this application from being Yet Another Native Web App framework.

### About

nodeAppKit is based on NodeLike, an open source project to implement a roughly Node.JS-compatible interface using JavaScriptCore.framework on iOS 7 and OS X Mavericks.

nodeAppKit is currently in an incomplete state, but does compile and runs basic node, connect, express and OWIN/JS applications.

It is conceptually similar to node-webkit and GitHub atom, but runs on mobile platforms, within appstores and even on servers, and doesnt require changes to server side code when porting a web app (or vice versa). 

### Features

- Integrated HTML5 standards based browser (webkit/trident) based browser, but with no 60Mb webkit executable (Chromium CEF optional on Windows instead of built-in IE11/Trident)

- Integrated node.js runtime (re-uses javascript code from node.js project with light weight native libraries and built in javascript engines, apple javascriptcore or microsoft chakra, instead of Chromium V8)

- Loads quickly as both webview and javascript engine are native to operating system, not linked libraries

- Designed to be app store friendly (Apple, Microsoft, Android -- see roadmap)

- Built in javascript debugger

- Requires no networking;  instead uses browser custom scheme to invoke HTTP-like requests to application in node.js or OWIN format with no ports opened

- Can use networking just like any other node app (libuv and http parser built in)

- Creates browser UI with no COCOA coding required

- Does not require special client side code;  just re-use your existing node.js express or connect applications, but run embedded within the app, not in a separate process or server

- Extensibility built in;  instead of hardcoding to undocumented node.js (req, res) interfaces, abstract web server as a standard implementation of an OWIN server (with translation back to node.js http/connect/express format for compatability)

	- OWIN/JS = Open Web Interface for .NET and node.js, with simple and [well-documented](http://owinjs.org) interface
	
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

```bash
git clone https://github.com/OwinJS/nodeAppKit.git`
```

Get the Cocoa Pod dependencies

```bash
pod install`
```

Replace all the files in the /web directory with your node.js application;  even though it runs on the mac/pc/device, write it as if it is server side

`package.json` and `index.js` contain the configuration and bootstrap code;  use `npm install` from the /web folder to install any node dependencies

use `require('owinjs')` instead of or in addition to `require('http')`

Compile in Xcode and Archive/Validate/Distribute for local applications and iTunes App Store.

### Roadmap

Create pod spec

Port rest of domaba framework (closed .NET source) to open source javascript in this project

Once working on OS X, intent is to add Windows Store and Windows desktop applications, with source compatability of applications; after that we'll do Windows Phone 8

Tested on OS X only, requires simple porting to iOS;  underlying frameworks are already portable.

Finally we will port to Android

In other words this will be a universal UI kit, with all code in javascript / 

### Frameworks

#### [OWIN/JS](http://owinjs.org)

#### [javascriptcore](http://asciiwwdc.com/2013/sessions/615)

#### [webkit](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DisplayWebContent/DisplayWebContent.html#//apple_ref/doc/uid/10000164i)

#### [node.js](http://nodejs.org)

#### [nodelike](https://github.com/node-app/Nodelike)

### License

Open source under Mozilla Public License 2.0.


### Author

nodeAppKit container framework hand-coded by OwinJS;  see frameworks above for respective authorship of the core components