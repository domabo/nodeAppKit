//
//  NAKURLFileDecode.h
//  The nodeAppKit Project
//
//  Created by Guy Barnard on 2/28/14.
//  Copyright (c) 2014 Guy Barnard. See License File for rights.
//
//  An OWIN/JS Reference Implementation
//

#import <Foundation/Foundation.h>

@interface NAKURLFileDecode : NSObject
-(NAKURLFileDecode *)initWithURLRequest:(NSURLRequest *)request;
-(BOOL)exists;

@property (strong, nonatomic) NSString *resourcePath; // The path to the bundle resource
@property (strong, nonatomic) NSString *urlPath; // The relative path from root
@property (strong, nonatomic) NSString *fileName; // The filename, with extension
@property (strong, nonatomic) NSString *fileBase; // The filename, without the extension
@property (strong, nonatomic) NSString *fileExtension; // The file extension
@property (strong, nonatomic) NSString *mimeType; // The mime type
@property (strong, nonatomic) NSString *textEncoding; // The text encoding
@end
