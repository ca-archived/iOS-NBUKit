//
//  NBUAssetsGroup.h
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

@class ALAssetsGroup;

/**
 Wrapper to ease acces to an ALAssetsGroup assets group.
 
 - Unlike ALAssetsGroup objects, NBUAssetsGroup is always valid.
 - Observes ALAssetsLibraryChangedNotification to reload its associated
 ALAssetsGroup if needed.
 - Lazily loads posterImage and assets' count only when needed.
 - Leverages iOS4 compatibility by creating a NSURL:
 `assets-library://group/?id=<ALAssetsGroupPropertyPersistentID>`.
 
 @note You usually retrieve assets groups using NBUAssetTypesLibrary methods.
 */
@interface NBUAssetsGroup : NSObject

/// @name Initializers

/// Creates and initializes a NBUAssetsGroup associated to a ALAssetsGroup.
/// @param ALAssetsGroup The associated ALAssetsGroup.
+ (NBUAssetsGroup *)groupForALAssetsGroup:(ALAssetsGroup *)ALAssetsGroup;

/// Creates and initializes a NBUAssetsGroup associated to a local directory.
/// @discussion Use [NBUAssetsLibrary registerDirectoryGroupforURL:name:] to let the
/// assets library automatically create and display the assets group for you.
/// @param directoryURL The target directory's URL.
/// @param name The optional name to be used for the NBUAssetsGroup.
+ (NBUAssetsGroup *)groupForDirectoryURL:(NSURL *)directoryURL
                                    name:(NSString *)name;

/// @name Properties

/// The NBUAssetsGroupType of the group.
@property (nonatomic, readonly)                     NBUAssetsGroupType type;

/// The group's name.
@property (nonatomic, readonly)                     NSString * name;

/// The associated NSURL.
/// @note For iOS4 the ALAssetsGroupPropertyPersistentID is converted to a NSURL.
@property (nonatomic, readonly)                     NSURL * URL;

/// Whether the group is editable or not.
@property(nonatomic, readonly, getter=isEditable)   BOOL editable;

/// A thumbnail-sized poster image.
@property (nonatomic, readonly)                     UIImage * posterImage;

/// The associated ALAssetsGroup.
@property (strong, nonatomic, readonly)             ALAssetsGroup * ALAssetsGroup;

/// @name Accessing Assets

/// The total number of assets.
@property (nonatomic, readonly)                     NSUInteger assetsCount;

/// The total number of image assets.
@property (nonatomic, readonly)                     NSUInteger imageAssetsCount;

/// The total number of video assets.
@property (nonatomic, readonly)                     NSUInteger videoAssetsCount;

/// @name Retrieving Assets

/// Returns the assets matching an ALAssetsFilter.
/// @param types The desired type mask of assets to retrieve.
/// @param indexSet The index of the desired assets. Pass `nil` to get all the assets.
/// @param reverseOrder Set to `YES` to get newer to older assets.
/// @param loadSize If different to zero the resultBlock will be called after loading another
/// loadSize number of assets.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)assetsWithTypes:(NBUAssetType)types
              atIndexes:(NSIndexSet *)indexSet
           reverseOrder:(BOOL)reverseOrder
    incrementalLoadSize:(NSUInteger)loadSize
            resultBlock:(NBUAssetsResultBlock)resultBlock;

/// Ask the group to abort retrieving assets, and thus stop calling the resultBlock.
- (void)stopLoadingAssets;

/// @name Adding Assets

/// Add a NBUAsset object to this group.
/// @param asset The asset to be added.
/// @note Only works on iOS5+.
- (BOOL)addAsset:(NBUAsset *)asset;

/// Asynchronously add a NBUAsset to the group.
/// @param assetURL The URL of the asset to be added.
/// @param resultBlock An optional block to be called to inform whether the asset
/// was added to the group.
/// @note Will only work on iOS5+.
- (void)addAssetWithURL:(NSURL *)assetURL
            resultBlock:(void (^)(BOOL success))resultBlock;

@end

