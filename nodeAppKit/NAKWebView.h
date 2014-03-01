//
//  NodeWebView.h
//  nodmob
//
//  Created by Guy Barnard on 2/15/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Webkit/Webkit.h"

@interface NAKWebView :  NSObject
+ (void) createWindow: (NSString*) urlAddress title:(NSString*)title  width:(int)x height:(int) y;
+ (void) createSplashWindow: (NSString*) urlAddress width:(int)x height:(int)y;
+ (void) closeSplashWindow;
+ (void) createDebugWindow;
@end