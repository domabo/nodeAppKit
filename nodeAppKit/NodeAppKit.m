#import "NodeAppKit.h"
#import "NAKOWIN.h"
#import "NAKWebView.h"

@implementation NodeAppKit
- (void) run {
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcePath = [mainBundle resourcePath];
    NSString *webPath = [resourcePath stringByAppendingPathComponent:@"/web"];
    NSString *nodeModulePathWeb = [webPath stringByAppendingPathComponent:@"/node_modules"];
    NSString *nodeModulePath = [resourcePath stringByAppendingPathComponent:@"/node_modules"];
   
    NSString *resPaths = [[[[[[webPath stringByAppendingString:@":"]
                            stringByAppendingString:nodeModulePathWeb]
                            stringByAppendingString:@":"]
                           stringByAppendingString: nodeModulePath ]
                           stringByAppendingString:@":"]
                          stringByAppendingString:resourcePath];
    
    NSString *index = [mainBundle pathForResource:@"index" ofType:@"js" inDirectory:@"web"];
    
    if (!index)
    {
        NSLog(@"Missing index.js in main bundle /Resources/web");
        return;
    }
    
    JSVirtualMachine* vm = [[JSVirtualMachine alloc]init];
    _context = [[NLContext alloc] initWithVirtualMachine:vm];
    _context[@"process"][@"env"][@"NODE_PATH"] = resPaths;
    _context[@"process"][@"workingDirectory"] = webPath;
    _context[@"process"][@"createWindow"] = ^(NSString* url, NSString* title, int width, int height){
        dispatch_async(dispatch_get_main_queue(), ^{
            [NAKWebView createWindow: url title:title width:width height:height];
              [NAKWebView closeSplashWindow];
        });
    };
   
    JSGlobalContextRetain([_context JSGlobalContextRef]);
    
    NSString *_nodeScript = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nodeappkit" ofType:@"js"] encoding:(NSUTF8StringEncoding) error:NULL];

    [_context evaluateScript:_nodeScript];
    
    JSGlobalContextRetain([_context JSGlobalContextRef]);
    
    [NAKOWIN attachToContext:_context];
    
    [_context evaluateScript:@"module._load(package['node-main'], null, true);"];
    
    [NLContext runEventLoopAsync];
}

@end
