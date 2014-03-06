//
//  NodeAppKit.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKWebViewDebug.h"
#import "NAKOWIN.h"
#import "NAKJSContextFactory.h"
#import <Nodelike/Nodelike.h>
#import "NodeAppKit.h"
#import "NAKWebView.h"

@implementation NodeAppKit
{
     NAKJSContextFactory *JSContextFactory;
}

- (void) run {
   JSContextFactory = [[NAKJSContextFactory alloc] init];
    
     [JSContextFactory create: ^ void (JSContext *context){
         [NAKWebView createSplashWindow: @"internal://localhost/owinjs-splash/views/StartupSplash.html" width:800 height:600];
         
   NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *resourcePath = [mainBundle resourcePath];
        NSString *webPath = [resourcePath stringByAppendingPathComponent:@"/web"];
        NSString *nodeModulePath = [resourcePath stringByAppendingPathComponent:@"/node_modules"];
        NSString *nodeModulePathWeb = [resourcePath stringByAppendingPathComponent:@"/web-shared/OwinJS"];
        NSString *nodeModulePathWeb2 = [resourcePath stringByAppendingPathComponent:@"/web-shared/node_modules"];
         
        NSString *resPaths = [[[[[[[[webPath stringByAppendingString:@":"]
                                  stringByAppendingString:nodeModulePathWeb]
                                 stringByAppendingString:@":"]
                                stringByAppendingString: nodeModulePathWeb2 ]
                               stringByAppendingString:@":"]
                              stringByAppendingString: nodeModulePath ]
                               stringByAppendingString:@":"]
                              stringByAppendingString:resourcePath];
        
        NSString *index = [mainBundle pathForResource:@"package" ofType:@"json" inDirectory:@"app"];
        
        if (!index)
        {
            NSLog(@"Missing package.json in main bundle /Resources/app");
            return;
        }
        
        context[@"process"][@"env"][@"NODE_PATH"] = resPaths;
        context[@"process"][@"workingDirectory"] = webPath;
        context[@"process"][@"createWindow"] = ^(NSString* url, NSString* title, int width, int height){
            dispatch_async(dispatch_get_main_queue(), ^{
                [NAKWebView createWindow: url title:title width:width height:height];
                [NAKWebView closeSplashWindow];
            });
        };
        
        JSGlobalContextRetain([context JSGlobalContextRef]);
        
        NSString *nodeappkitJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nodeappkit" ofType:@"js"] encoding:(NSUTF8StringEncoding) error:NULL];
        
        [context evaluateScript:nodeappkitJS];
        
        JSGlobalContextRetain([context JSGlobalContextRef]);
        
        [NAKOWIN attachToContext:context];
        [NAKWebViewDebug setThrowIfHandled:YES];
        [context evaluateScript:@"module._load(package['node-main'], null, true);"];
         [NAKWebViewDebug setThrowIfHandled:YES];
         
        [NLContext runEventLoopAsync];
    }];
}
@end
