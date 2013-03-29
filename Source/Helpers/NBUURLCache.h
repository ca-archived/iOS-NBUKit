//
//  NBUURLCache.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/26.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 A flexible NSURLCache subclass.
 
 - Force loading local files for remote requests.
 
 Sample usage:
 
     NBUURLCache * cache = [NBUURLCache new];
     [cache setLoadLocalFile:@"nbugap-1.2-ios.js"
     inDirectory:@"web"
     MIMEType:@"text/javascript"
     textEncodingName:@"utf-8"
     forRequestsWithURL:[NSURL URLWithString:@"http://172.17.127.150/public/nbubase/web/cordova2.1/samples/app/nbugap.js.php"]];
 */
@interface NBUURLCache : NSURLCache

/// @name Loading Local Files for Remote Requests

/// Set to load a local file for request with a matching URL.
/// @param filename The local file's name.
/// @param directory The local file's directory, relative to the the Application's bundle.
/// @param mime The file's MIME type.
/// @param encoding An optional text encoding name.
/// @param url The target URL.
- (void)setLoadLocalFile:(NSString *)filename
             inDirectory:(NSString *)directory
                MIMEType:(NSString *)mime
        textEncodingName:(NSString *)encoding
      forRequestsWithURL:(NSURL *)url;

/// Clear loading local files for requests matching the URL.
/// @param url The target URL.
- (void)clearLoadLocalFileForRequestsWithURL:(NSURL *)url;

@end

