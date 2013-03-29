//
//  NBUAssetView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/// NBUAsset image sizes.
enum
{
    NBUAssetImageSizeAuto           = 0,
    NBUAssetImageSizeThumbnail      = 1,
    NBUAssetImageSizeFullScreen     = 2,
    NBUAssetImageSizeFullResolution = 3,
};
typedef NSUInteger NBUAssetImageSize;

/**
 Customizable ObjectView used to present a NBUAsset object.
 
 - Automatically chooses the best-suited NBUAssetImageSize to display for the asset.
 */
@interface NBUAssetView : ObjectView

/// The associated NBUAsset asset
@property (strong, nonatomic, setter = setObject:, getter = object) NBUAsset * asset;

/// @name Properties

/// The target NBUAssetImageSize to be loaded.
///
/// Default NBUAssetImageSizeAuto which will choose the most appropiate size.
@property (nonatomic)                   NBUAssetImageSize targetImageSize;

/// The currently used NBUAssetImageSize.
@property (nonatomic)                   NBUAssetImageSize currentImageSize;

/// @name Outlets

/// An UIImageView used to show the [NBUAsset thumbnailImage].
@property (assign, nonatomic) IBOutlet  UIImageView * imageView;

@end

