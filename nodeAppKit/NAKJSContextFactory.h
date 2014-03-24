//
//  NAKJSContextFactory.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import <Foundation/Foundation.h>

@interface NAKJSContextFactory : NSObject
{
    void (^_completionHandler)(id context);

}
- (void) create: (void(^)(id))jsCallback;
@end
