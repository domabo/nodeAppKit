//
//  NAKWebView.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import <Foundation/Foundation.h>

@interface NAKWebView :  NSObject
+ (void) createWindow: (NSString*) urlAddress title:(NSString*)title  width:(int)x height:(int) y;
+ (void) createSplashWindow: (NSString*) urlAddress width:(int)x height:(int)y;
+ (void) closeSplashWindow;
+ (void) createDebugWindow;
+ (void) showDebugWindow: (NSDictionary*)exception;
@end