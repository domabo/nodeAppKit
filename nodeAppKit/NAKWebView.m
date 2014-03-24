//
//  NAKWebView.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKWebView.h"
#import "NAKURLProtocolCustom.h"
#import "NAKURLProtocolLocalFile.h"
#import "NAKOWIN.h"
#import "Webkit/Webkit.h"

static NSWindow *splashWindow = nil;
static NSMutableArray *mainWindows = nil;
static NSWindow *debugWindow = nil;
static WebView *debugWebView = nil;

@implementation NAKWebView
    
+ (void) createWindow : (NSString*) urlAddress title:(NSString*)title width:(int)x height:(int) y
    {
        NSRect windowRect = [[NSScreen mainScreen] frame];
        NSRect frameRect = NSMakeRect(
                                      (NSWidth(windowRect) - x)/2,
                                      (NSHeight(windowRect) - y)/2,
                                      x, y);
        
        NSRect viewRect = NSMakeRect(0,0,x, y);
        
        
        WebView* webview = [[WebView alloc] initWithFrame:viewRect];
        
        
        NSWindow *mainWindow = [[NSWindow alloc] initWithContentRect:frameRect
                                                           styleMask:NSTitledWindowMask | NSClosableWindowMask |NSResizableWindowMask
                                                             backing:NSBackingStoreBuffered
                                                               defer:NO screen:[NSScreen mainScreen]];
        
        if (mainWindows == nil)
        mainWindows =  [NSMutableArray array];
        
        [mainWindows addObject:mainWindow];
        
        [mainWindow makeKeyAndOrderFront:nil];
        [mainWindow setContentView:webview];
        [mainWindow setTitle: title];
        
        [webview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [[webview superview] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
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
        
        [webview setMaintainsBackForwardList:YES];
        NSString *appname = @"nodeAppKit";
        
        [webview setApplicationNameForUserAgent:appname];
        [webview setPreferences:webPrefs];
        [webview setDrawsBackground:false];
        
        [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
        [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
        
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [[webview mainFrame] loadRequest:requestObj];
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
        
 //       [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
   //     [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
+ (void) closeSplashWindow
    {
        if (splashWindow)
        {
            [splashWindow close];
        }
        
    }

+ (void) createDebugWindow
    {
        if (debugWindow != nil) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            int x = 1024;
            int y= 800;
            NSRect windowRect = [[NSScreen mainScreen] frame];
            NSRect frameRect = NSMakeRect(
                                          (NSWidth(windowRect) - x)/2,
                                          (NSHeight(windowRect) - y)/2,
                                          x, y);
            
            NSRect viewRect = NSMakeRect(0,0,x, y);
            
            debugWebView = [[WebView alloc] initWithFrame:viewRect];
            
            debugWindow = [[NSWindow alloc] initWithContentRect:frameRect
                                                      styleMask:NSTitledWindowMask | NSClosableWindowMask |NSResizableWindowMask
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO screen:[NSScreen mainScreen]];
            
            [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:debugWindow];
            
            [debugWindow makeKeyAndOrderFront:nil];
            [debugWindow setContentView:debugWebView];
            [debugWindow setTitle: @"Debug"];
            [debugWindow setReleasedWhenClosed:NO];
            
            [debugWebView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [[debugWebView superview] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            
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
            
            [debugWebView setMaintainsBackForwardList:NO];
            NSString *appname = @"nodeAppKit-debug";
            
            [debugWebView setApplicationNameForUserAgent:appname];
            [debugWebView setPreferences:webPrefs];
            [debugWebView setDrawsBackground:false];
            
            [NSURLProtocol registerClass:[NAKURLProtocolLocalFile class]];
            [NSURLProtocol registerClass:[NAKURLProtocolCustom class]];
            
            NSURL *url = [NSURL URLWithString:@"debug://localhost/"];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            [[debugWebView mainFrame] loadRequest:requestObj];
        });
        
    }
    
+ (void) showDebugWindow: (NSDictionary*)e
    {
        if (debugWindow == nil)
        [NAKWebView createDebugWindow];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSURL *url = [NSURL URLWithString:@"debug://localhost/"];
            NSMutableString *message = [NSMutableString stringWithCapacity:1000];
            [message appendString:@"<head></head>"];
            [message appendString:@"<body>"];
            [message appendString:@"<h1>Exception</h1>"];
            NSArray *callStack =e[@"callStack"];
            NSDictionary *locals = e[@"locals"];
            NSString *fileName;
            NSString *source = e[@"source"];
            if ([locals count] >0)
            {
                fileName = e[@"locals"][@"__filename"];
            }
            
            if (!fileName)
            {
                NSRange r1 = [source rangeOfString:@"sourceURL="];
                if (r1.location == NSNotFound)
                {
                    fileName = @"n/a";
                }
                else
                {
                    NSRange r2 = NSMakeRange(r1.location + r1.length,  [source length] - r1.location -r1.length);
                    NSRange r3 = [source rangeOfString:@"\n" options:0 range:r2];
                    if (r1.location == NSNotFound)
                    {
                        fileName = @"n/a";
                    }
                    else
                    {
                        NSRange rsub = NSMakeRange(r2.location,  r3.location -r2.location);
                        fileName = [source substringWithRange:rsub];
                    }
                }
            }
            
            [message appendFormat:@"<h2>%@</h2>", e[@"exception"]];
            [message appendFormat:@"<p><i>%@</i> in file %@ at line %@</p>" , e[@"description"], fileName, e[@"lineNumber"]];
            [message appendFormat:@"<h3>Source Line</h3><pre style='font-family: monospace;'>%@</pre>" , e[@"sourceLine"]];
            
            if ([callStack count] >0)
            {
                [message appendString:@"<h3>Call Stack</h3>"];
                [message appendString:@"<pre id='preview' style='font-family: monospace;'><ul>"];
                [callStack enumerateObjectsUsingBlock: ^(NSString* line, NSUInteger idx, BOOL* stop) {
                    [message appendFormat:@"<li>%@</li>", line];
                }];
                [message appendString:@"</ul></pre>"];
            }
            
            if ([source length] >0)
            {
                [message appendString:@"<h3>Source</h3>"];
                
                [message appendString:@"<pre id='preview' style='font-family: monospace; tab-size: 3; -moz-tab-size: 3; -o-tab-size: 3; -webkit-tab-size: 3;'><ol>"];
                
                
                [source enumerateLinesUsingBlock:^(NSString* line, BOOL* stop) {
                    [message appendFormat:@"<li>%@</li>", line];
                }];
                [message appendString:@"</ol></pre>"];
            }
            
            if ([locals count] >0)
            {
                [message appendString:@"<h3>Locals</h3>"];
                [message appendString:@"<pre style='font-family: monospace;'><table>"];
                
                [locals enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL* stop) {
                    [message appendFormat:@"<tr><td>%@</td><td>%@</td></tr>", key,obj];
                }];
                [message appendString:@"</table></pre>"];
            }
            
            
            
            [message appendString:@"</body>"];
            
            [[debugWebView mainFrame] loadHTMLString:message baseURL:url];
        });
        
    }
    
    
+ (void)windowWillClose:(NSNotification *)notification
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            debugWindow = nil;
        });
    }
    
    @end
