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
static dispatch_queue_t javascriptcoreQueue ;

@implementation NAKOWIN
+ (void)attachToContext:(JSContext *)context
{
    _context = context;
    javascriptcoreQueue = dispatch_queue_create("owinjs:javascriptcore", NULL);
}

+ (JSValue*) createOwinContext
{
    
    return [_context evaluateScript:@"process.owinJS.createEmptyContext();"];

}

+ (void) evaluateScript:(NSString * )script
{
 //   dispatch_async(javascriptcoreQueue, ^{
       [_context evaluateScript:script];
  //  });
    
}


+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack
{
  //   dispatch_async(javascriptcoreQueue, ^{
                   // [_context evaluateScript:@"console.log(require('util').inspect(process).replace('\\n','\\r')); dodg.asdasdas;"];
     [_context[@"process"][@"owinJS"][@"invokeContext"] callWithArguments:@[owinContext, callBack]];
 //   });
    
}
@end
