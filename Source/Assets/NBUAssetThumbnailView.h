//
//  NBUAssetThumbnailView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/08.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 NBUAssetView for NBUAssetImageSizeThumbnail images only and provides selection.
 */
@interface NBUAssetThumbnailView : NBUAssetView

/// @name Properties

/// Whether the view has been selected or not.
/// @note When tapped the view's superclass sends an ActiveViewTappedNotification.
@property (nonatomic, getter = isSelected)  BOOL selected;

/// @name Outlets

/// A view to be shown/hidden upon selection.
/// @see selected
@property (assign, nonatomic) IBOutlet      UIView * checkmark;

@end

