//
//  NBUPresetFilterView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/13.
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

#import "ObjectView.h"
#import "UIImageView+NBUAdditions.h"

@class NBUFilter, ObjectSlideView;

/**
 An view to ease applying preset filters to an image.
 
 - Simply use image setter and getter to apply the current filter.
 - Preset and arbitrary number of preset (preconfigured) filters.
 - NBUFilter thumbnails are presented in a ObjectSlideView.
 - Optimize performance using scaled down thumbnails and working images for previews.
 - Async image processing using Grand Dispatch Central.
 - Filtered previews' caching for quick switching between filters.
 - Observes UIApplicationDidReceiveMemoryWarningNotification to release cached previews on low memory conditions.
 - UI can be completely customized using Nib files.
 */
@interface NBUPresetFilterView : NBUView <UIImageView>

/// @name Setting and Getting Images

/// Set the original image, get the filtered image.
@property (strong, nonatomic)           UIImage * image;

/// The desired working size for the preview.
/// @note If not set, the size in pixels of the editingImageView will be used.
@property (nonatomic)                   CGSize workingSize;

/// @name Managing the Filters

/// The current set of filters.
@property (strong, nonatomic)           NSArray * filters;

/// The currently selected filter.
@property (strong, nonatomic)           NBUFilter * currentFilter;

/// @name Outlets

/// The working image preview.
@property (weak, nonatomic) IBOutlet    UIImageView * editingImageView;

/// An ObjectSlideView to display NBUFilterThumbnailView objects.
@property (weak, nonatomic) IBOutlet    ObjectSlideView * filterSlideView;

/// A view to be shown while async processing images.
@property (weak, nonatomic) IBOutlet    UIView * activityView;

/// A reset button automatically enabled/disabled.
@property (weak, nonatomic) IBOutlet    UIButton * resetButton;

/// @name Actions

/// Reset the image preview and current filter.
/// @param sender The sender object.
/// @note You can also use a NBUFilterTypeNone filter to reset the image.
- (IBAction)reset:(id)sender;

@end

