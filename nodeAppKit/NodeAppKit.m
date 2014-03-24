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
     dispatch_async(dispatch_get_main_queue(), ^{
    [NAKWebView createSplashWindow: @"internal://localhost/owinjs-splash/views/StartupSplash.html" width:800 height:600];
     });

   [JSContextFactory create: ^ void (JSContext *context){
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        NSString *appPath = [[mainBundle bundlePath] stringByDeletingLastPathComponent];
        NSString *resourcePath = [mainBundle resourcePath];
        NSString *webPath = [resourcePath stringByAppendingPathComponent:@"/app"];
        NSString *nodeModulePath = [resourcePath stringByAppendingPathComponent:@"/app/node_modules"];
        NSString *nodeModulePathWeb = [resourcePath stringByAppendingPathComponent:@"/app-shared"];
        NSString *nodeModulePathWeb2 = [resourcePath stringByAppendingPathComponent:@"/app-shared/node_modules"];
        
        NSString *appModulePath = [appPath stringByAppendingPathComponent:@"/node_modules"];
        
        NSString *externalPackage = [appPath stringByAppendingPathComponent:@"/package.json"];
        NSString *embeddedPackage = [webPath stringByAppendingPathComponent:@"/package.json"];
        
        NSString *resPaths;
        
        if ([fileManager fileExistsAtPath:externalPackage]){
            context[@"process"][@"workingDirectory"] = appPath;
            
              resPaths = [[[[[[[[resourcePath stringByAppendingString:@":"]
                              stringByAppendingString:appPath]
                             stringByAppendingString:@":"]
                            stringByAppendingString: nodeModulePathWeb ]
                           stringByAppendingString:@":"]
                          stringByAppendingString: nodeModulePathWeb2 ]
                         stringByAppendingString:@":"]
                        stringByAppendingString:appModulePath];
        }
        else
        {
            if (![fileManager fileExistsAtPath:embeddedPackage])
            {
                NSLog(@"Missing package.json in main bundle /Resources/app");
                return;
            }
            context[@"process"][@"workingDirectory"] = webPath;
            
            resPaths = [[[[[[[[resourcePath stringByAppendingString:@":"]
                              stringByAppendingString:webPath]
                             stringByAppendingString:@":"]
                            stringByAppendingString: nodeModulePathWeb ]
                           stringByAppendingString:@":"]
                          stringByAppendingString: nodeModulePathWeb2 ]
                         stringByAppendingString:@":"]
                        stringByAppendingString:nodeModulePath];
        }
        
        context[@"process"][@"env"][@"NODE_PATH"] = resPaths;
        context[@"process"][@"createWindow"] = ^(NSString* url, NSString* title, int width, int height){
            dispatch_async(dispatch_get_main_queue(), ^{
                [NAKWebView createWindow: url title:title width:width height:height];
                [NAKWebView closeSplashWindow];
            });
        };
        
     /*   context[@"process"][@"nextTick"] = ^(JSValue * cb) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [cb callWithArguments:@[]];
            });
        };*/
        
        context[@"process"][@"throwHandledErrors"] = ^(bool throwIfHandled){
#ifdef DEBUG
            [NAKWebViewDebug setThrowIfHandled:throwIfHandled];
#endif
        };
        
        context[@"process"][@"doEvents"] = ^(){
            [NLContext runProcessAsyncQueue: context];
        };
        
        
        context.exceptionHandler = ^(JSContext *ctx, JSValue *e) {
           NSLog(@"Context exception thrown: %@; stack: %@", e, [e valueForProperty:@"stack"]);
        };
        
        [NAKOWIN attachToContext:context];
        JSGlobalContextRetain([context JSGlobalContextRef]);
        
        // RUN SCRIPTS
#ifdef DEBUG
        [NAKWebViewDebug setThrowIfHandled:YES];
#endif
        NSString *nodeappkitJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nodeappkit" ofType:@"js"] encoding:(NSUTF8StringEncoding) error:NULL];
        
        [context evaluateScript:nodeappkitJS];
        [context evaluateScript:@"module._load(process.package['main'], null, true);"];
        [NLContext runEventLoopAsync];
#ifdef DEBUG
        [NAKWebViewDebug setThrowIfHandled:YES];
#endif
    }];
}
@end
