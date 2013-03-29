//
//  NBUEditImageViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/30.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/// NBUCameraView blocks.
typedef void (^NBUEditImageResultBlock)(UIImage * image);

@interface NBUEditImageViewController : NBUObjectViewController

/// The source image.
@property (strong, nonatomic, setter = setObject:, getter = object) UIImage * image;

/// The edited image.
/// @note Every time you call this method the image is processed again.
- (UIImage *)editedImage;

/// The optional block to be called when the apply: action is triggered.
@property (nonatomic, strong)           NBUEditImageResultBlock resultBlock;

/// @name Configuring Cropping

/// The size relative to the UIScreen points to be used to crop the image.
/// @see NBUCropView.
@property (nonatomic)                   CGSize cropGuideSize;

/// Maximum scale factor to be allowed to use.
/// @see NBUCropView.
@property (nonatomic)                   CGFloat maximumScaleFactor;

/// @name Configuring Filters

/// The current set of filters.
/// @see NBUPresetFilterView.
@property (strong, nonatomic)           NSArray * filters;

/// The desired working size for the preview.
/// @see NBUPresetFilterView.
@property (nonatomic)                   CGSize workingSize;

/// @name Outlets

/// The optional NBUPresetFilterView.
@property (assign, nonatomic) IBOutlet  NBUPresetFilterView * filterView;

/// The optional NBUCropView.
@property (assign, nonatomic) IBOutlet  NBUCropView * cropView;

/// @name Methods

/// Reset the crop and/or filter view.
/// @param sender The sender object.
- (IBAction)reset:(id)sender;

/// Apply the editions to the image and call the resul  tBlock if set.
/// @param sender The sender object.
- (IBAction)apply:(id)sender;

@end

