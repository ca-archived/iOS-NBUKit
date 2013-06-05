//
//  NBUEditImageViewController.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/30.
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

#import "NBUObjectViewController.h"

@class NBUMediaInfo, NBUPresetFilterView, NBUCropView;

/// NBUCameraView blocks.
typedef void (^NBUEditImageResultBlock)(UIImage * image);

/**
 A view controller to handle a NBUPresetFilterView and/or a NBUCropView.
 */
@interface NBUEditImageViewController : NBUObjectViewController

/// @name Hanlding Images

/// The source image.
@property (strong, nonatomic, setter=setObject:,
                              getter=object)        UIImage * image;

/// The edited image.
/// @note Every time you call this method the image is processed again.
- (UIImage *)editedImage;

/// The optional block to be called when the apply: action is triggered.
@property (nonatomic, copy)                         NBUEditImageResultBlock resultBlock;

/// @name Handling Media Info Objects

/// The source NBUMediaInfo object.
@property (strong, nonatomic)                       NBUMediaInfo * mediaInfo;

/// Update and return the mediaInfo with edition information.
- (NBUMediaInfo *)editedMediaInfo;

/// @name Configuring Cropping

/// An optional target size. If set edited images will be downsized to fit this size.
/// Default `CGSizeZero` which means no resizing of the cropped image.
@property (nonatomic)                               CGSize cropTargetSize;

/// The size relative to the UIScreen points to be used to crop the image.
/// @see NBUCropView.
@property (nonatomic)                               CGSize cropGuideSize;

/// Maximum scale factor to be allowed to use.
/// @see NBUCropView.
@property (nonatomic)                               CGFloat maximumScaleFactor;

/// @name Configuring Filters

/// The current set of filters.
/// @see NBUPresetFilterView.
@property (strong, nonatomic)                       NSArray * filters;

/// The desired working size for the preview.
/// @see NBUPresetFilterView.
@property (nonatomic)                               CGSize workingSize;

/// @name Outlets

/// The optional NBUPresetFilterView.
@property (assign, nonatomic) IBOutlet              NBUPresetFilterView * filterView;

/// The optional NBUCropView.
@property (assign, nonatomic) IBOutlet              NBUCropView * cropView;

/// @name Methods

/// Reset the crop and/or filter view.
/// @param sender The sender object.
- (IBAction)reset:(id)sender;

/// Apply the editions to the image and call the resul  tBlock if set.
/// @param sender The sender object.
- (IBAction)apply:(id)sender;

@end

