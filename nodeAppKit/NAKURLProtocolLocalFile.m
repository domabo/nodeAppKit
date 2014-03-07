//
//  NAKURLProtocolLocalFile.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKURLProtocolLocalFile.h"
#import "NAKURLFileDecode.h"

@implementation NAKURLProtocolLocalFile
    
+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
    {
        
        if (theRequest.URL.host == nil)
        return NO;
        
        if (([theRequest.URL.scheme caseInsensitiveCompare:@"internal"] == NSOrderedSame)
            || ([theRequest.URL.host caseInsensitiveCompare:@"internal"] == NSOrderedSame))
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
        
        NAKURLFileDecode *urlDecode = [[NAKURLFileDecode alloc] initWithURLRequest:[self request]];
        NSLog(@"Loading %@", [urlDecode fileName]);
        
        
        if ([urlDecode exists]) {
            NSData *data =  [NSData dataWithContentsOfFile:[urlDecode resourcePath]];
            
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[[self request] URL]
                                                                MIMEType:[urlDecode mimeType]
                                                   expectedContentLength:[data length]
                                                        textEncodingName:[urlDecode textEncoding]];
            
            [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
            [[self client] URLProtocol:self didLoadData:data];
            [[self client] URLProtocolDidFinishLoading:self];
            NSLog(@"%@", [urlDecode fileName]);
        }
        else {
            NSLog(@"Missing File %@", self.request.URL);
            
            [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
        }
    }
    
- (void)stopLoading
    {
    }
    
    @end