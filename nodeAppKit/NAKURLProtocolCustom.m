//
//  NAKURLProtocolCustom.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKURLProtocolCustom.h"
#import "NAKOWIN.h"

@implementation NAKURLProtocolCustom
{
    JSValue *context;
    bool isLoading;
    bool isCancelled;
}
    
+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
    {
        
        if (theRequest.URL.host == nil)
        return NO;
        
        if (([theRequest.URL.scheme caseInsensitiveCompare:@"node"] == NSOrderedSame)
            || ([theRequest.URL.host caseInsensitiveCompare:@"node"] == NSOrderedSame)
            ||   ([theRequest.URL.scheme caseInsensitiveCompare:@"debug"] == NSOrderedSame))
        {
            return YES;
        }
        return NO;
    }
    
+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
    {
        return theRequest;
    }
        
- (void)startLoading
{
    isCancelled = false;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"%@", [self.request.URL absoluteString]);
        
    context =[NAKOWIN createOwinContext];
    
    NSString *path = [self.request.URL relativePath];
    NSString *query =[self.request.URL query];
    
    if ([path isEqualToString: @""])
    path = @"/";
    
    if (query == nil)
    query = @"";
    
    context[@"owin.RequestPath"] = path;
    context[@"owin.RequestPathBase"] = @"";
    context[@"owin.RequestQueryString"] = query;
    context[@"owin.RequestHeaders"]  = self.request.allHTTPHeaderFields;
    context[@"owin.RequestMethod"] = self.request.HTTPMethod;
    context[@"owin.RequestIsLocal"] = @TRUE;
    context[@"owin.RequestScheme"] = [self.request.URL scheme];
    context[@"owin.RequestProtocol"] = @"HTTP/1.1";
    
    if ([self.request.HTTPMethod isEqualToString: @"POST"])
    {
        NSString *body = [NSString stringWithUTF8String:[self.request.HTTPBody bytes]];
        context[@"owin.RequestHeaders"][@"Content-Length"] = [[NSNumber numberWithInteger:body.length] stringValue];
        [context[@"owin.RequestBody"][@"setData"] callWithArguments:@[body]];
    }
    isLoading= YES;
    [NAKOWIN invokeAppFunc:context callBack:^ void (id error, id value){
        if (isCancelled)
          return;
        if (error != [NSNull null])
        {
            NSLog(@"Unhandled Server Error Occurred");
        }
        else
        {
            NSDictionary *headers = [context[@"owin.ResponseHeaders"] toDictionary];
            NSString *version = [context[@"owin.ResponseProtocol"] toString];
            NSString *dataString = [context[@"owin.ResponseBody"] toString];
            NSInteger statusCode = [[context[@"owin.ResponseStatusCode"] toString] longLongValue] ;
            
            if (statusCode == 302)
            {
                NSURL *url = [NSURL URLWithString: headers[@"location"]];
                NSLog(@"Redirection location to %@", url);
                
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode: statusCode HTTPVersion:version headerFields:headers];
                
                [[self client] URLProtocol:self wasRedirectedToRequest:[NSURLRequest requestWithURL:url] redirectResponse:response];
                isLoading= NO;
                [[self client] URLProtocolDidFinishLoading:self];
                
            }
            else
            {
                
                NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode: statusCode HTTPVersion:version headerFields:headers];
                
                NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                
                [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [[self client] URLProtocol:self didLoadData:data];
                isLoading= NO;
                [[self client] URLProtocolDidFinishLoading:self];
            }
        }
 
    } ];
    });
}

- (void)stopLoading
{
    
    if (isLoading)
    {
        isCancelled=YES;
        NSLog(@"CANCELLED");
        [NAKOWIN cancelOwinContext:context];
    }
    context = nil;
}

@end