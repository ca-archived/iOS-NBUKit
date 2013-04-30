//
//  NBUCropView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 12/04/16.
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

#import "NBUView.h"

@protocol UIImageView;

/**
 An ObjectView that alows users to crop images by pinching and dragging.
 
 - Set a cropGuideView and/or a cropSize relative.
 - Set the image 
 */
@interface NBUCropView : NBUView

/// @name Setting and Getting Images

/// Set the source image, get the cropped image.
@property (strong, nonatomic)           UIImage * image;

/// The current crop rect in image coordinates.
@property (nonatomic, readonly)         CGRect currentCropRect;

/// @name Configurable Properties

/// The size relative to the UIScreen points to be used to crop the image.
/// @discussion When set a default cropGuideView will be created if needed.
/// @note If not set the cropGuideView size will be used.
@property (nonatomic)                   CGSize cropGuideSize;

/// Maximum scale factor to be allowed to use. Default value `1.5`.
@property (nonatomic)                   CGFloat maximumScaleFactor;

/// Whether to allow the viewToCrop to "aspectFit" inside the cropGuideView. Defaul `NO`.
/// @discussion By default the crop view will try to "aspectFill" the viewToCrop.
@property (nonatomic)                   BOOL allowAspectFit;

/// @name Outlets

/// The view to be cropped. If not set a UIImageView will be created.
/// @discussion It can be a UIImageView, NBUPresetFilterView or any view that respondes implements
/// the UIImageView protocol.
@property (nonatomic, strong) IBOutlet  UIView<UIImageView> * viewToCrop;

/// The UIScrollView that handles panning and zooming the viewToCrop. If not set
/// one will be created.
@property (nonatomic, strong) IBOutlet  UIScrollView * scrollView;

/// An optional image to be displayed as reference for cropping.
/// @discussion If you don't want to use the default cropGuideView just set it to `nil`
/// after setting the cropGuideSize.
@property (nonatomic, strong) IBOutlet  UIView * cropGuideView;

@end

