//
//  NAKOWIN.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import <Foundation/Foundation.h>
#import <Nodelike/Nodelike.h>

typedef void (^nodeCallBack)(id error, id value);

@interface NAKOWIN: NSObject
+ (void)attachToContext:(JSContext *)context;
+ (JSValue*) createOwinContext;
+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack;
+ (void) cancelOwinContext:(JSValue *)owinContext;
+ (void) createResponseStream:(JSValue *)owinContext;
@end