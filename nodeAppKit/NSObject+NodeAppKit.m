//
//  NSObject+NodeAppKit.m
//  nodeAppKit
//
//  Created by Guy Barnard on 3/7/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import "NSObject+NodeAppKit.h"
#import "objc/runtime.h"

char env_dispatch_queue = 0;

@implementation NSObject (NodeAppKit)
    
- (id)nodeappkitGet:(void *)key {
    return objc_getAssociatedObject(self, key);
}
    
- (void)nodeappkitSet:(void *)key toValue:(id)value {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}
    
@end