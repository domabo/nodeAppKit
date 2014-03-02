//
//  NAKWebViewDebug.m
//  nodeAppKit
//
//  Created by Guy Barnard on 2/27/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//
#ifdef DEBUG

#import "NAKWebViewDebug.h"
#import "NAKWebView.h"

@class WebFrame;

/*@interface WebView
 - (void)setScriptDebugDelegate:(id)delegate;
 @end*/

@interface WebScriptCallFrame
- (id)exception;
- (NSString*)functionName;
- (WebScriptCallFrame*)caller;
- (NSArray *)scopeChain;
- (id)evaluateWebScript:(NSString *)script;
    @end

/*@interface WebScriptObject
 - (id)valueForKey:(NSString*)key;
 @end*/

@implementation NAKWebViewDebug
    
    static NSString* const kSourceIDMapFilenameKey = @"filename";
    static NSString* const kSourceIDMapSourceKey = @"source";
    static NSMutableDictionary* sourceIDMap;
    static NSDictionary *currentException = nil;
    static bool debuggerStopped = NO;
    
- (id)init
    {
        if ((self = [super init])) {
            sourceIDMap = [NSMutableDictionary dictionary];
            
        }
        
        return [super init];
    }
    
- (void)attachToContext:(JSContext*)context
    {
        context[@"process"][@"debugException"] = (NSDictionary*)^(){
            if (currentException == nil)
              currentException = @{ @"source" : @"",
                                    @"lineNumber" : @"",
                                    @"sourceLine" : @"",
                                    @"callStack" : [[NSMutableArray alloc] init],
                                    @"locals" : [[NSMutableArray alloc] init],
                                  @"exception" : @"",
                                  @"description" : @""};
            NSLog(@"DEBUG");
            return currentException;
            
        };
        
    }
    
+ (NSString*)filenameForURL:(NSURL*)url {
    NSString* pathString = [url path];
    NSArray* pathComponents = [pathString pathComponents];
    return [pathComponents objectAtIndex:([pathComponents count] - 1)];
}
    
+ (NSString*)formatSource:(NSString*)source {
    NSMutableString* formattedSource = [NSMutableString stringWithCapacity:100];
    [formattedSource appendString:@"Source:\n"];
    int* lineNumber = malloc(sizeof(int));
    *lineNumber = 1;
    [source enumerateLinesUsingBlock:^(NSString* line, BOOL* stop) {
        [formattedSource appendFormat:@"%3d: %@", *lineNumber, line];
        (*lineNumber)++;
    }];
    free(lineNumber);
    [formattedSource appendString:@"\n\n"];
    
    return formattedSource;
}
    
- (void) webView:(WebView*)webView didParseSource:(NSString*)source baseLineNumber:(unsigned int)baseLineNumber fromURL:(NSURL*)url sourceId:(int)sourceID forWebFrame:(WebFrame*)webFrame {
    NSString* filename = nil;
    if (url) {
        filename = [NAKWebViewDebug filenameForURL:url];
    }
    NSMutableDictionary* mapEntry = [NSMutableDictionary dictionaryWithObject:source forKey:kSourceIDMapSourceKey];
    if (filename) {
        [mapEntry setObject:filename forKey:kSourceIDMapFilenameKey];
    }
    [sourceIDMap setObject:mapEntry forKey:[NSNumber numberWithInt:sourceID]];
    //NSLog(@"%@", [source substringToIndex:MIN(300, [source length])]);
}
    
    
- (void)webView:(WebView *)webView failedToParseSource:(NSString *)source baseLineNumber:(unsigned int)baseLineNumber fromURL:(NSURL *)url withError:(NSError *)error forWebFrame:(WebFrame *)webFrame {
    
    if (  debuggerStopped )
    return;
    
    NSDictionary* userInfo = [error userInfo];
    NSNumber* fileLineNumber = [userInfo objectForKey:@"WebScriptErrorLineNumber"];
    NSString* description = [userInfo objectForKey:@"WebScriptErrorDescription"];
    
    NSString* filename = @"";
    if (url) {
        filename = [NSString stringWithFormat:@"filename: %@, ", [NAKWebViewDebug filenameForURL:url]];
    }
    
    
    NSArray* sourceLines = [source componentsSeparatedByString:@"\n"];
    NSString* sourceLine = [sourceLines objectAtIndex:([fileLineNumber intValue] - 1)];
    if ([sourceLine length] > 200) {
        sourceLine = [[sourceLine substringToIndex:200] stringByAppendingString:@"..."];
    }
    
    NSLog(@"Parse error - %@fileLineNumber: %d, sourceline: %@\n%@", filename, fileLineNumber, sourceLine, description);
    
    
    currentException = @{ @"source" :source,
                          @"lineNumber" : [fileLineNumber stringValue],
                          @"sourceLine" : sourceLine,
                          @"locals":     [[NSMutableArray alloc] init],
                          @"callStack" : [[NSMutableArray alloc] init],
                          @"exception" : @"Failed to Parse Source",
                          @"description" : description};
    debuggerStopped = YES;
    [NAKWebView createDebugWindow];
    
    
}
    
- (void)webView:(WebView *)webView exceptionWasRaised:(WebScriptCallFrame *)frame sourceId:(int)

sourceID line:(int)lineNumber forWebFrame:(WebFrame *)webFrame {
    
    WebScriptObject* exception = [frame exception];
    
    NSMutableArray *callStack = [[NSMutableArray alloc] init];
    
    bool tryFilePackage = NO;
    // Build the call stack.
    for (WebScriptCallFrame* currentFrame = frame; currentFrame; currentFrame = [currentFrame caller]) {
        
        if ([currentFrame functionName] == nil)
        if ([currentFrame caller] == nil)
        [callStack addObject:@"(global function)"];
        else
        [callStack addObject:@"(anonymous function)"];
        else
        {
            NSString *fname = [currentFrame functionName];
            
            if (([fname isEqualToString:@"tryFile"])
                || ([fname isEqualToString:@"tryPackage"]))
            tryFilePackage = YES;
            
            [callStack addObject: [currentFrame functionName]];
        }
    }
    
    
    if (([[exception valueForKey:@"message"] rangeOfString:@"no such file or directory"].location != NSNotFound) && (tryFilePackage))
    return;
    
    
    NSDictionary* sourceLookup = [sourceIDMap objectForKey:[NSNumber numberWithInt:sourceID]];
    NSString* filename = [sourceLookup objectForKey:kSourceIDMapFilenameKey];
    NSString* source = [sourceLookup objectForKey:kSourceIDMapSourceKey];
    
    NSMutableString *message = [NSMutableString stringWithCapacity:100];
    
    [message appendFormat:@"Exception\n\nName: %@", [exception valueForKey:@"name"]];
    
    if (filename) {
        [message appendFormat:@", filename: %@", filename];
    }
    
    [message appendFormat:@"\nMessage: %@\n\n", [exception valueForKey:@"message"]];
    
    NSArray* sourceLines = [source componentsSeparatedByString:@"\n"];
    NSString* sourceLine = [sourceLines objectAtIndex:(lineNumber - 1)];
    if ([sourceLine length] > 200) {
        sourceLine = [[sourceLine substringToIndex:200] stringByAppendingString:@"..."];
    }
    
    if ([sourceLine rangeOfString:@"delete Module._cache"].location != NSNotFound)
    return;
    NSMutableDictionary *localScope = [[NSMutableDictionary alloc] init];
    
    WebScriptObject *scope = [[frame scopeChain] objectAtIndex:0]; // local is always first
    NSArray *localScopeVariableNames = [NAKWebViewDebug webScriptAttributeKeysForScriptObject:scope];
    
    for (int i = 0; i < [localScopeVariableNames count]; ++i) {
        @try{
            
            NSString* key =[localScopeVariableNames objectAtIndex:i];
            NSString* value=[NAKWebViewDebug valueForScopeVariableNamed:key inCallFrame:frame];
            
            if ([value length] > 200) {
                value = [[value substringToIndex:200] stringByAppendingString:@"..."];
            }
            
            [localScope setObject:value forKey:key];
        }
        @catch (NSException * e) {
     //       NSLog(@"Warning: %@", e);
        }
        @finally {
         }
    }
    
    [message appendString:@"Offending function:\n"];
    [message appendFormat:@"  %d: %@\n", lineNumber, sourceLine];
    
    NSLog(@"%@", message);
    
   if (  debuggerStopped )
   return;

    currentException = @{ @"source" : source,
                          @"lineNumber" : [@(lineNumber) stringValue],
                          @"sourceLine" : sourceLine,
                          @"callStack" : callStack,
                          @"locals" : localScope,
                          @"exception" : [exception valueForKey:@"name"],
                          @"description" : [exception valueForKey:@"message"]};
    debuggerStopped = YES;
    
        double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NAKWebView createDebugWindow];
    });
    
}
    
+ (NSArray *)webScriptAttributeKeysForScriptObject:(WebScriptObject *)object
    {
        
        
        WebScriptObject *enumerateAttributes = [object evaluateWebScript:@"(function () { var result = new Array(); for (var x in this) { result.push(x); } return result; })"];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        WebScriptObject *variables = [enumerateAttributes callWebScriptMethod:@"call" withArguments:[NSArray arrayWithObject:object]];
        unsigned length = [[variables valueForKey:@"length"] intValue];
        for (unsigned i = 0; i < length; i++) {
            NSString *key = [variables webScriptValueAtIndex:i];
            [result addObject:key];
        }
        
        [result sortUsingSelector:@selector(compare:)];
        return result;
    }
    
    
    
+ (NSString *)valueForScopeVariableNamed:(NSString *)key inCallFrame:(WebScriptCallFrame *)frame
    {
        
        if (![[frame scopeChain] count])
        return nil;
        
        unsigned scopeCount = [[frame scopeChain] count] ;
        for (unsigned i = 0; i < scopeCount; i++) {
            WebScriptObject *scope = [[frame scopeChain] objectAtIndex:i];
            id value = [scope valueForKey:key];
            
            if ([value isKindOfClass:NSClassFromString(@"WebScriptObject")])
            return [value callWebScriptMethod:@"toString" withArguments:nil];
            if (value && ![value isKindOfClass:[NSString class]])
            return [value callWebScriptMethod:@"toString" withArguments:nil];
            return [NSString stringWithFormat:@"%@", value];
            if (value)
            return value;
        }
        
        return nil;
    }
    
    
    // just entered a stack frame (i.e. called a function, or started global scope)
    //- (void)webView:(WebView *)webView didEnterCallFrame:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame {}
    
    // about to execute some code
    //- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame;
    
    // about to leave a stack frame (i.e. return from a function)
    //- (void)webView:(WebView *)webView willLeaveCallFrame:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame;
    
    @end
#endif