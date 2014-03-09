//
//  NAKJSContextFactory.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKJSContextFactory.h"
#import <Nodelike/Nodelike.h>
#import "NAKWebView.h"
#import "NAKWebViewDebug.h"
#import "Webkit/Webkit.h"

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
#ifdef DEBUG
    _completionHandler = [jsCallback copy];
    [self createJavascriptWebView];
    return;
#else
    _completionHandler = [jsCallback copy];
    [self createJavascriptCore];
    
#endif
}

- (void) createJavascriptCore
{
    NSLog(@"Starting javascriptcore native engine");
    JSVirtualMachine* vm = [[JSVirtualMachine alloc]init];
    context = [[NLContext alloc] initWithVirtualMachine:vm];
    _completionHandler(context);
    _completionHandler = nil;
}

#ifdef DEBUG

- (void) createJavascriptWebView
{
    NSLog(@"Starting javascriptcore embedded engine");
    
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
    [debug attachToContext:ctx];
    
    _completionHandler(context);
    _completionHandler = nil;
}
#endif
@end
