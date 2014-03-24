//
//  NSObject+NodeAppKit.h
//  nodeAppKit
//
//  Created by Guy Barnard on 3/7/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern char env_dispatch_queue;

@interface NSObject (Nodelike)
    
- (id)nodeappkitGet:(void *)key;
- (void)nodeappkitSet:(void *)key toValue:(id)value;
    
@end
