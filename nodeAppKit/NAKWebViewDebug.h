//
//  NAKWebViewDebug.h
//  nodeAppKit
//
//  Created by Guy Barnard on 2/27/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Nodelike/Nodelike.h>

@interface NAKWebViewDebug : NSObject{
}
- (void)attachToContext:(JSContext*)context;

@end