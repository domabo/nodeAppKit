//
//  NAKJavascriptContextFactory.m
//  nodeAppKit
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import "NAKJSContextFactory.h"
#import <Nodelike/Nodelike.h>
#import "NAKWebView.h"
#import "NAKWebViewDebug.h"

@interface WebView ()
-(id)setScriptDebugDelegate:(id)delegate;
@end

@implementation NAKJSContextFactory
{
    JSContext *context;
    WebView *webView;
}

- (void) create: (void(^)(id))jsCallback
{
     _completionHandler = [jsCallback copy];
     [self createJavascriptWebView];
}

- (void) createJavascriptCore
{
    
    JSVirtualMachine* vm = [[JSVirtualMachine alloc]init];
    context = [[NLContext alloc] initWithVirtualMachine:vm];
    _completionHandler(context);
    _completionHandler = nil;
}

- (void) createJavascriptWebView
{
    webView = [[WebView alloc] init];
    
    WebPreferences *webPrefs =  [WebPreferences standardPreferences];
    
    [webPrefs setLoadsImagesAutomatically:NO];
    [webPrefs setAllowsAnimatedImages:NO];
    [webPrefs setAllowsAnimatedImageLooping:NO];
    [webPrefs setJavaEnabled:NO];
    [webPrefs setPlugInsEnabled:NO];
    [webPrefs setJavaScriptEnabled:YES];
    [webPrefs setJavaScriptCanOpenWindowsAutomatically:NO];
    [webPrefs setShouldPrintBackgrounds:NO];
    [webPrefs setUserStyleSheetEnabled:NO];
    
    [webView setMaintainsBackForwardList:YES];
    NSString *appname = @"nodeAppkit-javascript";
    
    [webView setApplicationNameForUserAgent:appname];
    [webView setPreferences:webPrefs];
    [webView setDrawsBackground:false];
    
    [webView setFrameLoadDelegate:self];
    
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [[webView mainFrame] loadRequest:requestObj];
   WebScriptObject *scriptObject = [webView windowScriptObject];
    [scriptObject setValue:@"TEST" forKey:@"TEST"];
}

- (void) webView: (id) sender didCreateJavaScriptContext: (JSContext*) ctx forFrame: (id) frame
{
    NAKWebViewDebug *debug = [[NAKWebViewDebug alloc] init];
    [webView setScriptDebugDelegate:debug];
  
    context =ctx;
    [NLContext attachToContext:ctx];
    _completionHandler(context);
    _completionHandler = nil;
}
@end
