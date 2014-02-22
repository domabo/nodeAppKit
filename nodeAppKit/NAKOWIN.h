//
//  OwinServer.h
//  nodmob
//
//  Created by Guy Barnard on 2/9/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Nodelike/Nodelike.h>

typedef void (^nodeCallBack)(id error, id value);

@interface NAKOWIN: NSObject
+ (void)attachToContext:(JSContext *)context;
+ (JSValue*) createOwinContext;
+ (void) invokeAppFunc:(JSValue *)owinContext callBack:(nodeCallBack)callBack;
@end