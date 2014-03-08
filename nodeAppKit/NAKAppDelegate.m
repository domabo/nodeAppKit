//
//  NAKAppDelegate.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKAppDelegate.h"
#import "NodeAppKit.h"
#import "NAKWebView.h"
#import "NAKOWIN.h"

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
