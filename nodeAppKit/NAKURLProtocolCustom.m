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
        
        
        NSLog(@"Loading URL %@", self.request.URL);
        dispatch_async(dispatch_get_main_queue(), ^{
            __block JSValue *context =[NAKOWIN createOwinContext];
            
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
            
            __weak NAKURLProtocolCustom *protocol = self;
            
            [NAKOWIN invokeAppFunc:context callBack:^ void (id error, id value){
                
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
                        
                        [[protocol client] URLProtocol:protocol wasRedirectedToRequest:[NSURLRequest requestWithURL:url] redirectResponse:response];
                        
                        [[protocol client] URLProtocolDidFinishLoading:protocol];
                        
                    }
                    else
                    {
                        
                        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode: statusCode HTTPVersion:version headerFields:headers];
                        
                        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                        
                        [[protocol client] URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                        [[protocol client] URLProtocol:protocol didLoadData:data];
                        [[protocol client] URLProtocolDidFinishLoading:protocol];
                    }
                }
                
            } ];
        });
    }
    
- (void)stopLoading
    {
    }
    
    @end