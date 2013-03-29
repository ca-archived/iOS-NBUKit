//
//  NBUPresetFilterView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/13.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "ObjectView.h"

@class ObjectSlideView;

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
@property (assign, nonatomic) IBOutlet  UIImageView * editingImageView;

/// An ObjectSlideView to display NBUFilterThumbnailView objects.
@property (assign, nonatomic) IBOutlet  ObjectSlideView * filterSlideView;

/// A view to be shown while async processing images.
@property (assign, nonatomic) IBOutlet  UIView * activityView;

/// A reset button automatically enabled/disabled.
@property (assign, nonatomic) IBOutlet  UIButton * resetButton;

/// @name Actions

/// Reset the image preview and current filter.
/// @param sender The sender object.
/// @note You can also use a NBUFilterTypeNone filter to reset the image.
- (IBAction)reset:(id)sender;

@end

