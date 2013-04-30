//
//  NBUMediaInfo.h
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

/// NBUMediaInfo attributes' keys.
extern NSString * const NBUMediaInfoOriginalMediaKey;
extern NSString * const NBUMediaInfoOriginalMediaURLKey;
extern NSString * const NBUMediaInfoOriginalAssetKey;
extern NSString * const NBUMediaInfoOriginalThumbnailKey;

extern NSString * const NBUMediaInfoEditedMediaKey;
extern NSString * const NBUMediaInfoEditedMediaURLKey;
extern NSString * const NBUMediaInfoEditedThumbnailKey;

extern NSString * const NBUMediaInfoCropRectKey;
extern NSString * const NBUMediaInfoFiltersKey;


/// NBUMediaInfo source types.
enum
{
    NBUMediaInfoSourceUnknown   = 0,
    NBUMediaInfoSourceCamera    = 1 << 0,
    NBUMediaInfoSourceLibrary   = 1 << 1,
};
typedef NSInteger NBUMediaInfoSource;


/**
 A wrapper class to manage an original image, its edited version, related
 NBUAsset or any arbritrary information.
 
 - Eases handling images from different sources.
 - Automatically purges images from memory when needed, writing and loading
 from temporary files tranparently.
 - Convenience methods to access and modify the attributes dictionary.
 - Add custom metadata to its attributes dictionary.
 */
@interface NBUMediaInfo : NSObject

/// @name Creating New Media Infos

/// Instantiate and configure a new object with a predefined attributes dictionary.
/// @param attributes The initial attributes' dictionary.
+ (NBUMediaInfo *)mediaInfoWithAttributes:(NSDictionary *)attributes;

/// Instantiate and configure a new object with a predefined originalImage.
/// @param image The initial originalImage.
+ (NBUMediaInfo *)mediaInfoWithOriginalImage:(UIImage *)image;

/// @name Properties

/// The underlaying dictionary that holds all values.
@property (nonatomic, strong)                       NSMutableDictionary * attributes;

/// The media info's original NBUMediaInfoSource.
@property (nonatomic, readonly)                     NBUMediaInfoSource source;

/// Whether the originalImage has an edited version.
@property (nonatomic, readonly, getter=isEdited)    BOOL edited;

/// @name Convenience Methods to Handle Images

/// The original image.
@property (nonatomic, strong)                       UIImage * originalImage;

/// The edited image.
/// @discussion If the image was not edited it returns the original image instead.
@property (nonatomic, strong)                       UIImage * editedImage;

/// Save both originalImage and editedImage to temporary files and remove from memory.
/// @discussion Images will be reloaded transparently as needed.
- (void)purgeImagesFromMemory;

/// Create and cache an originalImage's thumbnail of a given size.
/// @param size The target size of the thumbnail.
- (UIImage *)originalThumbnailWithSize:(CGSize)size;

/// Create and cache an editedImage's thumbnail of a given size.
/// @param size The target size of the thumbnail.
- (UIImage *)editedThumbnailWithSize:(CGSize)size;

@end

