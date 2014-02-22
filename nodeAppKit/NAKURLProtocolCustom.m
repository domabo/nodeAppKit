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
        || ([theRequest.URL.host caseInsensitiveCompare:@"node"] == NSOrderedSame))
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
    
    __block JSValue *owinContext = [NAKOWIN createOwinContext];
    
    NSString *url = [self.request.URL absoluteString];
    
    owinContext[@"owin.RequestPath"] = url;
    
    __weak NAKURLProtocolCustom *protocol = self;
    
    [NAKOWIN invokeAppFunc:owinContext callBack:^ void (id error, id value){
        
       if (error != [NSNull null])
        {
          NSLog(@"Error occurred");
            
            // to do return 500 error //
        }
        else
        {
            NSDictionary *headers = [owinContext[@"owin.ResponseHeaders"] toDictionary];
            NSString *version = [owinContext[@"owin.ResponseProtocol"] toString];
            NSString *dataString = [owinContext[@"owin.ResponseBody"] toString];
            NSInteger statusCode = [[owinContext[@"owin.ResponseStatusCode"] toString] longLongValue] ;
            
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