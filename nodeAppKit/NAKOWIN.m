//
//  OwinServer.m
//  nodmob
//
//  Created by Guy Barnard on 2/9/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import "NAKOWIN.h"

static JSContext *_context = nil;

@implementation NAKOWIN
+ (void)attachToContext:(JSContext *)context
{
    _context = context;
     [_context evaluateScript:
     @"require('owin');\n"
        ];
}

+ (JSValue*) createOwinContext
{
    return [_context evaluateScript:@"process.owin.createContext()"];
}

+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack
{
      [_context[@"process"][@"owin"][@"invokeContext"] callWithArguments:@[owinContext, callBack]];
}

@end
