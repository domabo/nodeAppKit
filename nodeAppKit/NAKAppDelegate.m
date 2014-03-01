//
//  NAAppDelegate.m
//  node-appkit
//
//  Created by Guy Barnard on 2/15/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import "NAKAppDelegate.h"
#import "NodeAppKit.h"
#import "NAKWebView.h"
#import "NAKOWIN.h"

@interface WebView (WebPrivate)
+ (void)_enableRemoteInspector;
@end

@implementation NAKAppDelegate
{
    NodeAppKit *nodeAppKit;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"AMainMenu"], *subMenu;
    
    subMenu = [[NSMenu alloc] initWithTitle:@"domaba"];
    
    [menu setSubmenu:subMenu forItem:[menu addItemWithTitle:@"domaba" action:Nil keyEquivalent:@""]];
    
    [subMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [subMenu addItemWithTitle:@"Debug" action:@selector(Debug:) keyEquivalent:@"d"];
                                                       
    [[NSApplication sharedApplication] setMainMenu:menu];
    
    [NAKWebView createSplashWindow: @"internal://localhost/domaba/views/StartupSplash.html" width:800 height:600];
    
    
    @autoreleasepool {
        nodeAppKit = [[NodeAppKit alloc] init];
        [nodeAppKit run];
    }
}
                                                       
- (void)Debug:(id)sender
{
    [NAKWebView createDebugWindow];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return TRUE;
}
@end
