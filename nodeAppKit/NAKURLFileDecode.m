//
//  NAKURLFileDecode.m
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import "NAKURLFileDecode.h"

@implementation NAKURLFileDecode
    
-(NAKURLFileDecode *)initWithURLRequest:(NSURLRequest *)request
    {
        _resourcePath = nil;
        
        NSDictionary *fileTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"text/html", @"html",
                                   @"application/javascript", @"js",
                                   @"text/css", @"css",
                                   nil];
        
        _urlPath = [[[request URL] path] stringByDeletingLastPathComponent];
        _fileExtension= [[[request URL] pathExtension] lowercaseString];
        _fileName = [[request URL] lastPathComponent];
        if ([_fileExtension length] == 0)
        {
            _fileBase = _fileName;
            
        }
        else
        {
            _fileBase = [_fileName substringToIndex:([_fileName length] - ([_fileExtension length] + 1))];
        }
        
        if ([_fileName length] > 0) {
            _resourcePath = [[NSBundle mainBundle]
                             pathForResource:_fileBase ofType:_fileExtension inDirectory: [@"app" stringByAppendingPathComponent:_urlPath]];
            
            if ((_resourcePath == nil) && ([_fileExtension length] >0))
            _resourcePath = [[NSBundle mainBundle]
                             pathForResource:_fileBase ofType:_fileExtension inDirectory: [@"app-shared" stringByAppendingPathComponent:_urlPath]];
            
            
            if ((_resourcePath == nil) && ([_fileExtension length] ==0))
            _resourcePath = [[NSBundle mainBundle]
                             pathForResource:_fileBase ofType:@"html" inDirectory: [@"app" stringByAppendingPathComponent:_urlPath]];
            
            if ((_resourcePath == nil) && ([_fileExtension length] ==0))
            _resourcePath = [[NSBundle mainBundle]
                             pathForResource:@"index" ofType:@"html" inDirectory: [@"app" stringByAppendingPathComponent:[[request URL] path]]];
            
            _mimeType = nil;
            _textEncoding = nil;
            
            _mimeType = [fileTypes objectForKey:_fileExtension];
            
            if (_mimeType != nil) {
                if ([_mimeType hasPrefix:@"text"]) {
                    _textEncoding = @"utf-8";
                }
            }
        }
        
        return self;
    }
    
-(BOOL)exists
    {
        return (_resourcePath != nil);
    }
    
    @end
