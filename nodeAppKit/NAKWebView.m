//
//  NodeWebView.m
//  nodmob
//
//  Created by Guy Barnard on 2/15/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import "NAKWebView.h"
#import "NAKURLProtocolCustom.h"
#import "NAKURLProtocolLocalFile.h"

static NSWindow *splashWindow = nil;
static NSMutableArray *mainWindows = nil;


@implementation NAKWebView
+ (void) createWindow : (NSString*) urlAddress title:(NSString*)title width:(int)x height:(int) y;
{
    NSRect windowRect = [[NSScreen mainScreen] frame];
    NSRect frameRect = NSMakeRect(
                                  (NSWidth(windowRect) - x)/2,
                                  (NSHeight(windowRect) - y)/2,
                                  x, y);
    
    NSRect viewRect = NSMakeRect(0,0,x, y);
    
    
    WebView *webView = [[WebView alloc] initWithFrame:viewRect];
    
    NSWindow *mainWindow = [[NSWindow alloc] initWithContentRect:frameRect
                                                       styleMask:NSTitledWindowMask | NSClosableWindowMask |NSResizableWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO screen:[NSScreen mainScreen]];
    
    if (mainWindows == nil)
        mainWindows =  [NSMutableArray array];
    
    [mainWindows addObject:mainWindow];
    
    [mainWindow makeKeyAndOrderFront:nil];
    [mainWindow setContentView:webView];
    [mainWindow setTitle: title];
    
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[webView superview] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    WebPreferences *webPrefs =  [WebPreferences standardPreferences];
    
    [webPrefs setLoadsImagesAutomatically:YES];
    [webPrefs setAllowsAnimatedImages:YES];
    [webPrefs setAllowsAnimatedImageLooping:YES];
    [webPrefs setJavaEnabled:NO];
    [webPrefs setPlugInsEnabled:NO];
    [webPrefs setJavaScriptEnabled:YES];
    [webPrefs setJavaScriptCanOpenWindowsAutomatically:NO];
    [webPrefs setShouldPrintBackgrounds:YES];
    [webPrefs setUserStyleSheetEnabled:NO];
    
    [webView setMaintainsBackForwardList:YES];
    NSString *appname = @"node-appkit";
    
    [webView setApplicationNameForUserAgent:appname];
    [webView setPreferences:webPrefs];
    [webView setDrawsBackground:false];
    
    [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
    [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:requestObj];
}

+ (void) createSplashWindow: (NSString*) urlAddress width:(int)x height:(int) y;
{
    NSRect windowRect = [[NSScreen mainScreen] frame];
    NSRect frameRect = NSMakeRect(
                                  (NSWidth(windowRect) - x)/2,
                                  (NSHeight(windowRect) - y)/2,
                                  x, y);
    
    NSRect viewRect = NSMakeRect(0,0,x, y);
    
    WebView *webView = [[WebView alloc] initWithFrame:viewRect];
    
    splashWindow = [[NSWindow alloc] initWithContentRect:frameRect
                                               styleMask:NSBorderlessWindowMask
                                                 backing:NSBackingStoreBuffered
                                                           defer:NO screen:[NSScreen mainScreen]];
    
    [splashWindow orderFront:self];
    [splashWindow setContentView:webView];
    [splashWindow setIsVisible:YES];
    
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[webView superview] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    WebPreferences *webPrefs =  [WebPreferences standardPreferences];
    
    [webPrefs setLoadsImagesAutomatically:YES];
    [webPrefs setAllowsAnimatedImages:YES];
    [webPrefs setAllowsAnimatedImageLooping:YES];
    [webPrefs setJavaEnabled:NO];
    [webPrefs setPlugInsEnabled:NO];
    [webPrefs setJavaScriptEnabled:YES];
    [webPrefs setJavaScriptCanOpenWindowsAutomatically:NO];
    [webPrefs setShouldPrintBackgrounds:YES];
    [webPrefs setUserStyleSheetEnabled:NO];
    
    [webView setMaintainsBackForwardList:YES];
    NSString *appname = @"node-appkit";
    
    [webView setApplicationNameForUserAgent:appname];
    [webView setPreferences:webPrefs];
    [webView setDrawsBackground:false];
    
    [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
    [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:requestObj];
}

+ (void) closeSplashWindow
{
    if (splashWindow)
    {
        [splashWindow close];
    }

 }

@end
