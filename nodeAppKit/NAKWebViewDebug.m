//
//  NAKWebViewDebug.m
//  nodeAppKit
//
//  Created by Guy Barnard on 2/27/14.
//  Copyright (c) 2014 domabo. All rights reserved.
//
#ifdef DEBUG

#import "NAKWebViewDebug.h"

@class WebFrame;

@interface WebView
- (void)setScriptDebugDelegate:(id)delegate;
@end

@interface WebScriptCallFrame
- (id)exception;
- (NSString*)functionName;
- (WebScriptCallFrame*)caller;
@end

@interface WebScriptObject
- (id)valueForKey:(NSString*)key;
@end

@implementation NAKWebViewDebug

static NSString* const kSourceIDMapFilenameKey = @"filename";
static NSString* const kSourceIDMapSourceKey = @"source";
static NSMutableDictionary* sourceIDMap;

- (id)init
{
    if ((self = [super init])) {
        sourceIDMap = [NSMutableDictionary dictionary];

    }
    
    return [super init];
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
        NSLog(filename);
        [mapEntry setObject:filename forKey:kSourceIDMapFilenameKey];
    }
    [sourceIDMap setObject:mapEntry forKey:[NSNumber numberWithInt:sourceID]];
    //NSLog(@"%@", [source substringToIndex:MIN(300, [source length])]);
}


- (void)webView:(WebView *)webView failedToParseSource:(NSString *)source baseLineNumber:(unsigned int)baseLineNumber fromURL:(NSURL *)url withError:(NSError *)error forWebFrame:(WebFrame *)webFrame {
    NSDictionary* userInfo = [error userInfo];
    NSNumber* fileLineNumber = [userInfo objectForKey:@"WebScriptErrorLineNumber"];
    
    NSString* filename = @"";
    NSMutableString* sourceLog = [NSMutableString stringWithCapacity:100];
    if (url) {
        filename = [NSString stringWithFormat:@"filename: %@, ", [NAKWebViewDebug filenameForURL:url]];
    } else {
        [sourceLog appendString:[[self class] formatSource:source]];
    }
    NSLog(@"Parse error - %@baseLineNumber: %d, fileLineNumber: %@\n%@", filename, baseLineNumber, fileLineNumber, sourceLog);
    
    //    assert(false);
}

- (void)webView:(WebView *)webView exceptionWasRaised:(WebScriptCallFrame *)frame sourceId:(int)

    sourceID line:(int)lineNumber forWebFrame:(WebFrame *)webFrame {
    
    WebScriptObject* exception = [frame exception];
    
    NSMutableString *callStack = [NSMutableString stringWithCapacity:100];
    
    
    // Build the call stack.
    for (WebScriptCallFrame* currentFrame = frame; currentFrame; currentFrame = [currentFrame caller]) {
        [callStack appendFormat:@"  %@\n", [currentFrame functionName]];
    }
    
    if (([[exception valueForKey:@"message"] rangeOfString:@"no such file or directory"].location != NSNotFound) && ([callStack rangeOfString:@"tryFile"].location!= NSNotFound))
    {
         return;
    }
    
    if ([[exception valueForKey:@"message"] rangeOfString:@"no such file or directory"].location != NSNotFound)
    if (([callStack rangeOfString:@"tryFile"].location!= NSNotFound) || ([callStack rangeOfString:@"tryPackage"].location!= NSNotFound))
        return;
    
    
    NSDictionary* sourceLookup = [sourceIDMap objectForKey:[NSNumber numberWithInt:sourceID]];
    assert(sourceLookup);
    NSString* filename = [sourceLookup objectForKey:kSourceIDMapFilenameKey];
    NSString* source = [sourceLookup objectForKey:kSourceIDMapSourceKey];
    
    NSMutableString *message = [NSMutableString stringWithCapacity:100];
    
    [message appendFormat:@"Exception\n\nName: %@", [exception valueForKey:@"name"]];
    
    if (filename) {
        [message appendFormat:@", filename: %@", filename];
    }
    
    [message appendFormat:@"\nMessage: %@\n\n", [exception valueForKey:@"message"]];
    
    /*if (!filename) {
        [message appendString:[[self class] formatSource:source]];
    }*/
    
    NSArray* sourceLines = [source componentsSeparatedByString:@"\n"];
    NSString* sourceLine = [sourceLines objectAtIndex:(lineNumber - 1)];
    if ([sourceLine length] > 200) {
        sourceLine = [[sourceLine substringToIndex:200] stringByAppendingString:@"..."];
    }
    
    //    NSString* firstLine = [sourceLines objectAtIndex:0];
    //    firstLine = [firstLine stringByReplacingOccurrencesOfString:@";(function() {var module = {exports:{}}; var exports = module.exports;var " withString:@""];
    
    [message appendString:@"Offending function:\n"];
    [message appendFormat:@"  %d: %@\n", lineNumber, sourceLine];
    //    [message appendFormat:@"file: %@\n", firstLine];
    
    if ([sourceLine rangeOfString:@"delete Module._cache"].location != NSNotFound)
        return;
    
    [message appendString:@"\nCall stack:\n"];
    [message appendString:callStack];
    
    NSLog(@"%@", message);
    
  /*  NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [BTApp notify:@"app.error" info:info];
    });*/
}

// just entered a stack frame (i.e. called a function, or started global scope)
//- (void)webView:(WebView *)webView didEnterCallFrame:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame {}

// about to execute some code
//- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame;

// about to leave a stack frame (i.e. return from a function)
//- (void)webView:(WebView *)webView willLeaveCallFrame:(WebScriptCallFrame *)frame sourceId:(int)sid line:(int)lineno forWebFrame:(WebFrame *)webFrame;

@end
#endif