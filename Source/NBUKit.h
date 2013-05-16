//
//  NBUKit.h
//  NBUKit
//
//  Created by Ernesto Rivera on 12/07/11.
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

/// NBUCore
#import <NBUCore/NBUCore.h>

/// NBUCompatibility
#import "ActiveView.h"
#import "ObjectView.h"
#import "ObjectArrayView.h"
#import "ObjectSlideView.h"
#import "ObjectGridView.h"
#import "ObjectTableView.h"
#import "ScrollViewController.h"

/// NBUKit
#import "NBULog+NBUKit.h"
#import "NBUApplicationDelegate.h"
#import "UIImageView+NBUAdditions.h"
#import "NBUView.h"
#import "NBUViewController.h"
#import "NBUObjectView.h"
#import "NBUObjectViewController.h"
#import "NBUSplashView.h"
#import "NBURefreshControl.h"
#import "NBUTabBarController.h"
#import "NBURotatingViews.h"
#import "NBUBadgeView.h"
#import "NBUBadgeSegmentedControl.h"
#import "NBUAssetsLibrary.h"
#import "NBUAssetsLibraryViewController.h"
#import "NBUAsset.h"
#import "NBUAssetView.h"
#import "NBUAssetThumbnailView.h"
#import "NBUAssetsGroup.h"
#import "NBUAssetsGroupView.h"
#import "NBUAssetsGroupViewController.h"
#import "NBUCameraView.h"
#import "NBUCameraViewController.h"
#import "NBUMockHelper.h"
#import "NBUURLCache.h"
#import "NBUFilter.h"
#import "NBUFilterGroup.h"
#import "NBUFilterProvider.h"
#import "NBUGPUImageFilterProvider.h"
#import "NBUCoreImageFilterProvider.h"
#import "NBUPresetFilterView.h"
#import "NBUFilterThumbnailView.h"
#import "NBUCropView.h"
#import "NBUEditImageViewController.h"
#import "NBUEditMultiImageViewController.h"
#import "NBUMediaInfo.h"
#import "NBUImageLoader.h"
#import "NBUGalleryView.h"
#import "NBUGalleryThumbnailView.h"
#import "NBUGalleryViewController.h"
#import "NBUImagePickerController.h"
#import "NBUMailComposeViewController.h"


/**
 NBUKit static library
 */
@interface NBUKit : NSObject

/// The current NBUKit library version.
+ (NSString *)version;

/// The NBUKitResources NSBundle.
+ (NSBundle *)resourcesBundle;

@end

