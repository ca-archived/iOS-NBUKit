//
//  NBUImageLoader.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/17.
//  Copyright (c) 2013 CyberAgent Inc.
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

#import "NBUImageLoader.h"

NSString * const NBUImageLoaderErrorDomain = @"NBUImageLoaderErrorDomain";

static NBUImageLoader * _sharedLoader;

@implementation NBUImageLoader

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedLoader = [NBUImageLoader new];
    });
}

+ (NBUImageLoader *)sharedLoader
{
    return _sharedLoader;
}

- (void)imageForObject:(id)object
                  size:(NBUImageSize)size
           resultBlock:(NBUImageLoaderResultBlock)resultBlock
{
    // Already an image?
    if ([object isKindOfClass:[UIImage class]])
    {
        resultBlock(object,
                    nil);
        return;
    }
    
    // An asset?
    if ([object isKindOfClass:[NBUAsset class]])
    {
        switch (size)
        {
            case NBUImageSizeThumbnail:
            {
                resultBlock(((NBUAsset *)object).thumbnailImage,
                            nil);
                return;
            }
            case NBUImageSizeFullScreen:
            {
                resultBlock(((NBUAsset *)object).fullScreenImage,
                            nil);
                return;

            }
            case NBUImageSizeFullResolution:
            default:
            {
                resultBlock(((NBUAsset *)object).fullResolutionImage,
                            nil);
                return;

            }
        }
        return;
    }
    
    // Media info?
    if ([object isKindOfClass:[NBUMediaInfo class]])
    {
        switch (size)
        {
            case NBUImageSizeThumbnail:
            {
                resultBlock([(NBUMediaInfo *)object editedThumbnailWithSize:CGSizeMake(100.0, 100.0)],
                            nil);
                return;
            }
            case NBUImageSizeFullScreen:
            case NBUImageSizeFullResolution:
            default:
            {
                resultBlock(((NBUMediaInfo *)object).editedImage,
                            nil);
                return;
            }
        }
        return;
    }
    
    // A url?
    // ...
    
    // Give up
    NSError * error = [NSError errorWithDomain:NBUImageLoaderErrorDomain
                                          code:NBUImageLoaderObjectKindNotSupported
                                      userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:
                                                                              @"Image loader can't handle object: %@", object]}];
    NBULogError(@"%@ %@", THIS_METHOD, error.localizedDescription);
    resultBlock(nil,
                error);
}

@end

