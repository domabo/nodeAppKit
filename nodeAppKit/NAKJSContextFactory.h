//
//  NAKJavascriptContextFactory.h
//  nodeAppKit
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Webkit/Webkit.h"

@interface NAKJSContextFactory : NSObject
{
    void (^_completionHandler)(id context);

}
- (void) create: (void(^)(id))jsCallback;

@end
