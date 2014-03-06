//
//  NAKWebViewDebug.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import <Foundation/Foundation.h>
#import <Nodelike/Nodelike.h>

@interface NAKWebViewDebug : NSObject{
}
- (void)attachToContext:(JSContext*)context;
+ (bool) throwIfHandled;
+ (void) setThrowIfHandled:(bool)val;
@end
