//
//  NBUURLCache.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/26.
//  Copyright (c) 2012 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NBUURLCache.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_HELPERS

@implementation NBUURLCache
{
    NSMutableDictionary * _cachedResponses;
}

- (void)setLoadLocalFile:(NSString *)filename
             inDirectory:(NSString *)directory
                MIMEType:(NSString *)mime
        textEncodingName:(NSString *)encoding
      forRequestsWithURL:(NSURL *)url
{
    NSString * path = [[NSBundle mainBundle] pathForResource:filename
                                                      ofType:nil
                                                 inDirectory:directory];
    // Get the local file contents
    if (!path)
    {
        NBULogError(@"File %@ at directory %@ couldn't be found in the main bundle",
                   filename, directory);
        return;
    }
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    // Save it as a cached response
    @synchronized (self)
    {
        if (!_cachedResponses)
        {
            _cachedResponses = [NSMutableDictionary dictionary];
        }
        
        NSURLResponse * response = [[NSURLResponse alloc] initWithURL:url
                                                             MIMEType:mime
                                                expectedContentLength:-1
                                                     textEncodingName:encoding];
        NSCachedURLResponse * cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response
                                                                                        data:data];
        _cachedResponses[url] = cachedResponse;
        NBULogInfo(@"Set to load %@ for requests with url %@", path, url);
    }
}

- (void)clearLoadLocalFileForRequestsWithURL:(NSURL *)url
{
    @synchronized (self)
    {
        _cachedResponses[url] = nil;
        NBULogInfo(@"Cleared load local file for requests with url %@", url);
    }
}

#pragma mark - Overridden methods

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    // Try our cached local files first
    NSCachedURLResponse * response = _cachedResponses[request.URL];
    if (response)
    {
        NBULogVerbose(@"Returning local file for request %@", request);
        return response;
    }

    // Else try super
    return [super cachedResponseForRequest:request];
}

@end

