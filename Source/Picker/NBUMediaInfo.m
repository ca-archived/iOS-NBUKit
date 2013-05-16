//
//  NBUMediaInfo.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/05.
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

#import "NBUMediaInfo.h"
#import "NBUKitPrivate.h"

// Media info keys
NSString * const NBUMediaInfoOriginalMediaKey       = @"NBUMediaInfoOriginalMedia";
NSString * const NBUMediaInfoOriginalThumbnailKey   = @"NBUMediaInfoOriginalThumbnail";
NSString * const NBUMediaInfoOriginalMediaURLKey    = @"NBUMediaInfoOriginalMediaURL";
NSString * const NBUMediaInfoOriginalAssetKey       = @"NBUMediaInfoOriginalAsset";
NSString * const NBUMediaInfoEditedMediaKey         = @"NBUMediaInfoEditedMedia";
NSString * const NBUMediaInfoEditedThumbnailKey     = @"NBUMediaInfoEditedThumbnail";
NSString * const NBUMediaInfoEditedMediaURLKey      = @"NBUMediaInfoEditedMediaURL";
NSString * const NBUMediaInfoCropRectKey            = @"NBUMediaInfoCropRect";
NSString * const NBUMediaInfoFiltersKey             = @"NBUMediaInfoFilters";

@implementation NBUMediaInfo

@synthesize attributes = _attributes;

+ (NBUMediaInfo *)mediaInfoWithAttributes:(NSDictionary *)attributes
{
    NBUMediaInfo * mediaInfo = [NBUMediaInfo new];
    mediaInfo.attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    return mediaInfo;
}

+ (NBUMediaInfo *)mediaInfoWithOriginalImage:(UIImage *)image
{
    NBUMediaInfo * mediaInfo = [NBUMediaInfo new];
    mediaInfo.originalImage = image;
    return mediaInfo;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _attributes = [NSMutableDictionary dictionary];
        
        // Register for memory warnings
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(purgeImagesFromMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)purgeImagesFromMemory
{
    // Purge original image
    UIImage * image = _attributes[NBUMediaInfoOriginalMediaKey];
    if (image &&
        !_attributes[NBUMediaInfoOriginalAssetKey] &&
        !_attributes[NBUMediaInfoOriginalMediaURLKey])
    {
        _attributes[NBUMediaInfoOriginalMediaURLKey] = [image writeToTemporaryDirectory];
    }
    [_attributes removeObjectForKey:NBUMediaInfoOriginalMediaKey];
    
    // Purge edited image
    image = _attributes[NBUMediaInfoEditedMediaKey];
    if (image &&
        !_attributes[NBUMediaInfoEditedMediaURLKey])
    {
        _attributes[NBUMediaInfoEditedMediaURLKey] = [image writeToTemporaryDirectory];
    }
    [_attributes removeObjectForKey:NBUMediaInfoEditedMediaKey];
}
                    
- (UIImage *)originalImage
{
    UIImage * image = _attributes[NBUMediaInfoOriginalMediaKey];
    
    // If still nil try to get it from the original asset or original URL
    if (!image)
    {
        if (_attributes[NBUMediaInfoOriginalAssetKey])
        {
            image = ((NBUAsset *)_attributes[NBUMediaInfoOriginalAssetKey]).fullResolutionImage;
        }
        else if (_attributes[NBUMediaInfoOriginalMediaURLKey])
        {
            image = [UIImage imageWithContentsOfFileURL:_attributes[NBUMediaInfoOriginalMediaURLKey]];
        }
    }
    
    return image;
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    [_attributes setValue:originalImage
                   forKey:NBUMediaInfoOriginalMediaKey];
    
    // Remove outdated objects
    [_attributes removeObjectForKey:NBUMediaInfoOriginalMediaURLKey];
    [_attributes removeObjectForKey:NBUMediaInfoOriginalAssetKey];
    for (NSString * key in _attributes.allKeys)
    {
        if ([key containsString:NBUMediaInfoOriginalThumbnailKey])
        {
            [_attributes removeObjectForKey:key];
        }
    }
}

- (UIImage *)editedImage
{
    UIImage * editedImage = _attributes[NBUMediaInfoEditedMediaKey];
    
    // If still nil try to get it from the edited URL
    if (!editedImage &&
        _attributes[NBUMediaInfoEditedMediaURLKey])
    {
        editedImage = [UIImage imageWithContentsOfFileURL:_attributes[NBUMediaInfoEditedMediaURLKey]];
    }
    
    // Fall back to the original image if needed
    return editedImage ? editedImage : self.originalImage;
}

- (void)setEditedImage:(UIImage *)editedImage
{
    [_attributes setValue:editedImage
                   forKey:NBUMediaInfoEditedMediaKey];
    
    // Remove outdated objects
    [_attributes removeObjectForKey:NBUMediaInfoEditedMediaURLKey];
    for (NSString * key in _attributes.allKeys)
    {
        if ([key containsString:NBUMediaInfoEditedThumbnailKey])
        {
            [_attributes removeObjectForKey:key];
        }
    }
}

- (NBUMediaInfoSource)source
{
    if (_attributes[NBUMediaInfoOriginalAssetKey])
    {
        return NBUMediaInfoSourceLibrary;
    }
    else if (_attributes)
    {
        return NBUMediaInfoSourceCamera;
    }
    else
    {
        return NBUMediaInfoSourceUnknown;
    }
}

- (UIImage *)originalThumbnailWithSize:(CGSize)size
{
    // Try cache
    NSString * key = [NSString stringWithFormat:@"%@%dx%d",
                      NBUMediaInfoOriginalThumbnailKey, (NSUInteger)size.width, (NSUInteger)size.height];
    UIImage * thumbnail = _attributes[key];
    
    // Not cached?
    if (!thumbnail)
    {
        thumbnail = [self.originalImage thumbnailWithSize:size];
        
        // Cache it
        _attributes[key] = thumbnail;
    };
    
    return thumbnail;
}

- (UIImage *)editedThumbnailWithSize:(CGSize)size
{
    // Try cache
    NSString * key = [NSString stringWithFormat:@"%@%dx%d",
                      NBUMediaInfoEditedThumbnailKey, (NSUInteger)size.width, (NSUInteger)size.height];
    UIImage * thumbnail = _attributes[key];
    
    // Not cached?
    if (!thumbnail)
    {
        thumbnail = [self.editedImage thumbnailWithSize:size];
        
        // Cache it
        _attributes[key] = thumbnail;
    };
    
    return thumbnail;
}

- (BOOL)isEdited
{
    return (_attributes[NBUMediaInfoEditedMediaKey] != nil ||
            _attributes[NBUMediaInfoEditedMediaURLKey] != nil);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: %@>", NSStringFromClass([self class]), self, _attributes.description];
}

@end

