//
//  NAKOWIN.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKOWIN.h"

static JSContext *_context = nil;

@implementation NAKOWIN
+ (void)attachToContext:(JSContext *)context
    {
        _context = context;
    }
    
+ (JSValue*) createOwinContext
    {
        return [_context evaluateScript:@"process.owinJS.createEmptyContext();"];
    }
    
+ (void) createResponseStream:(JSValue *)owinContext callBack:(nodeCallBack)callBack
    {
        [_context[@"process"][@"owinJS"][@"createResponseStream"] callWithArguments:@[owinContext, callBack]];
        [NLContext runProcessAsyncQueue:_context];
    }
    
+ (void) cancelOwinContext:(JSValue *)owinContext
    {
        [_context[@"process"][@"owinJS"][@"cancelContext"] callWithArguments:@[owinContext]];
        [NLContext runProcessAsyncQueue:_context];
    }
    
+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack
    {
        [_context[@"process"][@"owinJS"][@"invokeContext"] callWithArguments:@[owinContext, callBack]];
        [NLContext runProcessAsyncQueue:_context];
    }
    @end
