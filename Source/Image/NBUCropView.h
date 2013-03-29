//
//  NBUCropView.h
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/04/16.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "ObjectView.h"

/**
 An ObjectView that alows users to crop images by pinching and dragging.
 
 - Set a cropGuideView and/or a cropSize relative.
 - Set the image 
 */
@interface NBUCropView : NBUView

/// @name Setting and Getting Images

/// Set the source image, get the cropped image.
@property (strong, nonatomic)           UIImage * image;

/// @name Configurable Properties

/// The size relative to the UIScreen points to be used to crop the image.
///
/// @note If not set the cropGuideView size will be used.
@property (nonatomic)                   CGSize cropGuideSize;

/// Maximum scale factor to be allowed to use. Default value `1.5`.
@property (nonatomic)                   CGFloat maximumScaleFactor;

/// Whether to allow the viewToCrop to "aspectFit" inside the cropGuideView. Defaul `NO`.
///
/// By default the crop view will try to "aspectFill" the viewToCrop.
@property (nonatomic)                   BOOL allowAspectFit;

/// @name Outlets

/// The view to be cropped. If not set a UIImageView will be created.
///
/// It can be a UIImageView, NBUPresetFilterView or any view that respondes implements
/// the UIImageView protocol.
@property (nonatomic, strong) IBOutlet  UIView<UIImageView> * viewToCrop;

/// The UIScrollView that handles panning and zooming the viewToCrop. If not set
/// one will be created.
@property (nonatomic, strong) IBOutlet  UIScrollView * scrollView;

/// An optional image to be displayed as reference for cropping.
/// @note If not set you should directly set cropSize.
@property (nonatomic, strong) IBOutlet  UIView * cropGuideView;

@end

