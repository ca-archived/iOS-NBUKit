//
//  NBUImageLoader.h
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

/// The NBUImageLoader result block.
typedef void (^NBUImageLoaderResultBlock)(UIImage * image,
                                          NSError * error);

/// Possible NBUImageSize values.
enum
{
    NBUImageSizeAny             = 0,
    NBUImageSizeThumbnail       = 1,
    NBUImageSizeFullScreen      = 2,
    NBUImageSizeFullResolution  = 3
};
typedef NSUInteger NBUImageSize;

/// Error constants.
extern NSString * const NBUImageLoaderErrorDomain;
enum
{
    NBUImageLoaderObjectKindNotSupported    = -101,
};

/**
 A general protocol for asynchronous image loaders.
 */
@protocol NBUImageLoader <NSObject>

/// Retrieve an image related to an arbitrary object.
/// @param object The reference object the loader should use to load an image.
/// @param size The desired NBUImageSize.
/// @param resultBlock The callback result block to be called once the image
/// is loaded.
- (void)imageForObject:(id)object
                  size:(NBUImageSize)size
           resultBlock:(NBUImageLoaderResultBlock)resultBlock;

@optional

/// Optionally the loader can provide captions for objects.
/// @param object The reference object.
- (NSString *)captionForObject:(id)object;

/// TODO:
/// @param object The reference object.
- (void)unloadImageForObject:(id)object;

@end


/**
 A default NBUImageLoader that can handle UIImage, NBUAsset and NBUMediaInfo
 instances.
 */
@interface NBUImageLoader : NSObject <NBUImageLoader>

/// Retrieve the shared singleton.
+ (NBUImageLoader *)sharedLoader;

@end

