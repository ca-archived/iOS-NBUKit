//
//  NBUAsset.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/01.
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

#import "NBUAssetsLibrary.h"

@class ALAsset, CLLocation;

/// NBUAsset orientations.
enum
{
    NBUAssetOrientationUnknown      = 0,
    NBUAssetOrientationPortrait     = 1,
    NBUAssetOrientationLandscape    = 2,
};
typedef NSUInteger NBUAssetOrientation;

/**
 Wrapper to ease acces to an ALAsset image asset.
 
 - Unlike ALAsset objects, NBUAsset is always valid.
 - Observes ALAssetsLibraryChangedNotification to reload its associated ALAsset if needed.
 - Lazily loads all properties only when needed (except URL).
 
 @note You usually retrieve assets using NBUAssetsLibrary or NBUAssetsGroup methods.
 */
@interface NBUAsset : NSObject

/// @name Retrieving Assets

/// Creates and initializes a NBUAsset associated to an ALAsset.
/// @param ALAsset The associated ALAsset.
+ (NBUAsset *)assetForALAsset:(ALAsset *)ALAsset;

/// Creates and initializes a NBUAsset associated to a local file.
/// @param fileURL The Local file's URL.
+ (NBUAsset *)assetForFileURL:(NSURL *)fileURL;

/// @name Properties

/// The asset type.
@property (nonatomic, readonly)                     NBUAssetType type;

/// The associated NSURL.
@property (nonatomic, readonly)                     NSURL * URL;

/// The images orientation, portrait or landscape.
@property (nonatomic, readonly)                     NBUAssetOrientation orientation;

/// Whether the asset is editable or not.
@property(nonatomic, readonly, getter=isEditable)   BOOL editable;

/// The asset creation date.
@property (nonatomic, readonly)                     NSDate * date;

/// The asset location.
@property (nonatomic, readonly)                     CLLocation * location;

/// Associated ALAsset.
@property (nonatomic, readonly)                     ALAsset * ALAsset;

/// @name Images

/// A thumbnail-sized image.
@property (nonatomic, readonly)                     UIImage * thumbnailImage;

/// An image big enough to fill the device's screen.
@property (nonatomic, readonly)                     UIImage * fullScreenImage;

/// The full resolution image.
@property (nonatomic, readonly)                     UIImage * fullResolutionImage;

@end

