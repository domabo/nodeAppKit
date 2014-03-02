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
#import "NAKOWIN.h"

static NSWindow *splashWindow = nil;
static NSMutableArray *mainWindows = nil;
static NSWindow *debugWindow = nil;

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
    NSString *appname = @"nodeAppKit";
    
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
    NSString *appname = @"nodeAppKit-splash";
    
    [webView setApplicationNameForUserAgent:appname];
    [webView setPreferences:webPrefs];
    [webView setDrawsBackground:false];
    
    [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
    [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:requestObj];
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) closeSplashWindow
{
    if (splashWindow)
    {
        [splashWindow close];
    }

 }

+ (void) createDebugWindow;
{
    
    if (debugWindow != nil) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    int x = 800;
    int y= 600;
    NSRect windowRect = [[NSScreen mainScreen] frame];
    NSRect frameRect = NSMakeRect(
                                  (NSWidth(windowRect) - x)/2,
                                  (NSHeight(windowRect) - y)/2,
                                  x, y);
    
    NSRect viewRect = NSMakeRect(0,0,x, y);
    
    WebView *webView = [[WebView alloc] initWithFrame:viewRect];
    
    debugWindow = [[NSWindow alloc] initWithContentRect:frameRect
                                                       styleMask:NSTitledWindowMask | NSClosableWindowMask |NSResizableWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO screen:[NSScreen mainScreen]];
    
    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:debugWindow];
    
    [debugWindow makeKeyAndOrderFront:nil];
    [debugWindow setContentView:webView];
    [debugWindow setTitle: @"Debug"];
    [debugWindow setReleasedWhenClosed:NO];
        
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
    
    [webView setMaintainsBackForwardList:NO];
    NSString *appname = @"nodeAppKit-debug";
    
    [webView setApplicationNameForUserAgent:appname];
    [webView setPreferences:webPrefs];
    [webView setDrawsBackground:false];
    
    [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
    [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
    
    NSURL *url = [NSURL URLWithString:@"debug://localhost"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:requestObj];
    });
    
}

+ (void)windowWillClose:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
       debugWindow = nil;
    });
}


@end
