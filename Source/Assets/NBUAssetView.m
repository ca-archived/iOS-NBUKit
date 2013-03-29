//
//  NBUAssetView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetView.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUAssetView

@dynamic asset;
@synthesize targetImageSize = _targetImageSize;
@synthesize currentImageSize = _currentImageSize;
@synthesize imageView = _imageView;

- (void)setObject:(NBUAsset *)asset
{
    super.object = asset;
    
    // Force image update on next layoutSubviews
    _imageView.image = nil;
    _currentImageSize = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Create an UIImageView if needed
    if (!_imageView)
    {
        UIImageView * imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight);
        imageView.clipsToBounds = YES;
        imageView.frame = self.bounds;
        [self insertSubview:imageView
                    atIndex:0];
        _imageView = imageView;
    }
    
    // Update the image view
    [self updateImageView];
}

- (void)updateImageView
{
    // Specified?
    if (_targetImageSize != NBUAssetImageSizeAuto)
    {
        self.currentImageSize = _targetImageSize;
        return;
    }
    
    // Auto thumbnail?
    if (self.size.width <= 75.0 &&
        self.size.height <= 75.0)
    {
        self.currentImageSize = NBUAssetImageSizeThumbnail;
        NBULogVerbose(@"%@: NBUAssetImageSizeAuto thumbnail %@",
                   self, NSStringFromCGSize(_imageView.image.size));
        return;
    }
    
    // Auto full screen?
    CGSize estimatedSize = [UIScreen mainScreen].bounds.size;
    if (self.asset.orientation == NBUAssetOrientationLandscape)
        estimatedSize = CGSizeMake(estimatedSize.height, estimatedSize.width);
    if (self.size.width <= estimatedSize.width &&
        self.size.height <= estimatedSize.height)
    {
        self.currentImageSize = NBUAssetImageSizeFullScreen;
        NBULogVerbose(@"%@: NBUAssetImageSizeAuto fullScreen %@",
                   self, NSStringFromCGSize(_imageView.image.size));
        return;
    }
    
    // Auto full resolution
    self.currentImageSize = NBUAssetImageSizeFullResolution;
    NBULogVerbose(@"%@: NBUAssetImageSizeAuto fullResolution %@",
               self, NSStringFromCGSize(_imageView.image.size));
}

- (void)setCurrentImageSize:(NBUAssetImageSize)currentImageSize
{
    // No need to update?
    if (_currentImageSize == currentImageSize)
        return;
    
    _currentImageSize = currentImageSize;
    
    switch (currentImageSize)
    {
        case NBUAssetImageSizeThumbnail:
            _imageView.image = self.asset.thumbnailImage;
            return;
        
        case NBUAssetImageSizeFullScreen:
            _imageView.image = self.asset.fullScreenImage;
            return;
            
        default:
            _imageView.image = self.asset.fullResolutionImage;
            return;
    }
}

@end

