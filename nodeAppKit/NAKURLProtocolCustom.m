//
//  NSURLProtocolCustom.m
//  nodmob
//
//  Created by Guy Barnard on 2/9/14.
//  Copyright (c) 2014 domabo. All rights reserved.
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
    
    __block JSValue *owin = [NAKOWIN createOwinContext];
    
    NSString *path = [self.request.URL relativePath];
    NSString *query =[self.request.URL query];
    
    if ([path isEqualToString: @""])
      path = @"/";
    
    if (query == nil)
      query = @"";
    
    owin[@"Request"][@"Path"] = path;
    owin[@"Request"][@"PathBase"] = @"";
    owin[@"Request"][@"QueryString"] = query;
    owin[@"Request"][@"Headers"]  = self.request.allHTTPHeaderFields;
    owin[@"Request"][@"Method"] = self.request.HTTPMethod;
    owin[@"Request"][@"IsLocal"] = @TRUE;
    owin[@"Request"][@"Scheme"] = [self.request.URL scheme];
    
    if ([self.request.HTTPMethod isEqualToString: @"POST"])
    {
       NSString *body = [NSString stringWithUTF8String:[self.request.HTTPBody bytes]];
        owin[@"Request"][@"Headers"][@"Content-Length"] = [[NSNumber numberWithInteger:body.length] stringValue];
       [owin[@"Request"][@"Body"][@"setData"] callWithArguments:@[body]];
    }
    
    __weak NAKURLProtocolCustom *protocol = self;
    
    [NAKOWIN invokeAppFunc:owin callBack:^ void (id error, id value){
       if (error != [NSNull null])
        {
          NSLog(@"Unhandled Server Error Occurred");
        }
        else
        {
            NSDictionary *headers = [owin[@"Response"][@"Headers"] toDictionary];
            NSString *version = [owin[@"Response"][@"rotocol"] toString];
            NSString *dataString = [owin[@"Response"][@"Body"] toString];
            NSInteger statusCode = [[owin[@"Response"][@"StatusCode"] toString] longLongValue] ;
            
            if (statusCode == 302)
            {
                NSURL *url = [NSURL URLWithString: headers[@"Location"]];
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
}

- (void)stopLoading
{
}

@end