#import <Foundation/Foundation.h>
#import <Nodelike/Nodelike.h>

@interface NodeAppKit : NSObject

@property (strong) NLContext *context;
- (void) run;
@end