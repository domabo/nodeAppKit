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
    
}

+ (JSValue*) createOwinContext
{
    return [_context evaluateScript:@"process.owinJS.createEmptyContext();"];
    
 //   return [_context[@"process"][@"owinJS"][@"createEmptyContext"] callWithArguments:@[]];
    
  // return [JSValue valueWithNewObjectInContext:_context];
}

+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack
{
      [_context[@"process"][@"owinJS"][@"invokeContext"] callWithArguments:@[owinContext, callBack]];
}
@end
