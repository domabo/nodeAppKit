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
#import <Nodelike/NLBuffer.h>

@implementation NAKURLProtocolCustom
{
    __block JSValue *context;
    bool isLoading;
    bool isCancelled;
  __block  bool headersWritten;
}
    
 //   static NSMutableArray * instanceArray;
    
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
        //  [instanceArray addObject:self];
        __block NAKURLProtocolCustom *this = self;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", [this.request.URL absoluteString]);
            
            context =[NAKOWIN createOwinContext];
            
            NSString *path = [this.request.URL relativePath];
            NSString *query =[this.request.URL query];
            
            if ([path isEqualToString: @""])
            path = @"/";
            
            if (query == nil)
            query = @"";
            
            context[@"owin.RequestPath"] = path;
            context[@"owin.RequestPathBase"] = @"";
            context[@"owin.RequestQueryString"] = query;
            context[@"owin.RequestHeaders"]  = this.request.allHTTPHeaderFields;
            context[@"owin.RequestMethod"] = this.request.HTTPMethod;
            context[@"owin.RequestIsLocal"] = @TRUE;
            context[@"owin.RequestScheme"] = [this.request.URL scheme];
            context[@"owin.RequestProtocol"] = @"HTTP/1.1";
            
            if ([this.request.HTTPMethod isEqualToString: @"POST"])
            {
         //       NSString *body = [NSString stringWithUTF8String:[this.request.HTTPBody bytes]];
                NSString *body =[[NSString alloc] initWithData:[this.request.HTTPBody bytes] encoding:NSUTF8StringEncoding];
                
                context[@"owin.RequestHeaders"][@"Content-Length"] = [[NSNumber numberWithInteger:body.length] stringValue];
                [context[@"owin.RequestBody"][@"setData"] callWithArguments:@[body]];
            }
            isLoading= YES;
            headersWritten=NO;
            
           [NAKOWIN createResponseStream:context];
            
            context[@"owin.ResponseBody"][@"_writeBuffer"] = ^{
                JSValue *buffer = context[@"owin._ResponseBodyChunk"];
                int size = [NLBuffer getLength:buffer];
                NSData * data = [NSData dataWithBytes:[NLBuffer getData:buffer ofSize:size] length:size ];
                if (!headersWritten)
                [this writeHeaders];
                
                [[this client] URLProtocol:this didLoadData:data];
                
                data = nil;
            };
            
            context[@"owin.ResponseBody"][@"_writeString"] = ^{
                NSString *str = [context[@"owin._ResponseBodyChunk"] toString];
                NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
                if (!headersWritten)
                [this writeHeaders];
                
                [[self client] URLProtocol:self didLoadData:data];
                
                data = nil;
            };

            
            [NAKOWIN invokeAppFunc:context callBack:^ void (id error, id value){
                if (isCancelled)
                return;
                if (error != [NSNull null])
                {
                    NSLog(@"Unhandled Server Error Occurred");
                }
                else
                {
                    if (!headersWritten)
                    [this writeHeaders];
                    
                    isLoading= NO;
                    [[this client] URLProtocolDidFinishLoading:this];
                }
            }];
        });
    }
  
    
- (void)writeHeaders
    {
        headersWritten=YES;
        NSDictionary *headers = [context[@"owin.ResponseHeaders"] toDictionary];
        NSString *version = [context[@"owin.ResponseProtocol"] toString];
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
            
            [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
         }
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