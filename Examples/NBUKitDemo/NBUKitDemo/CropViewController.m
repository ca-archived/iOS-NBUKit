//
//  CropViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/07/31.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "CropViewController.h"

@implementation CropViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Configure the controller
    self.cropGuideSize = CGSizeMake(247.0, 227.0); // Matches our cropGuideView's image
    self.maximumScaleFactor = 10.0;                // We may get big pixels with this factor!
    
    // Our test image
    self.image = [UIImage imageNamed:@"photo.jpg"];
    
    // Our resultBlock
    __unsafe_unretained CropViewController * weakSelf = self;
    self.resultBlock = ^(UIImage * image)
    {
        // *** Do whatever you want with the resulting image here ***
        
        // Preview the changes
        weakSelf.cropView.image = image;
    };
}

- (void)setCropView:(NBUCropView *)cropView
{
    super.cropView = cropView;
    
    cropView.allowAspectFit = YES; // The image can be downsized until it fits inside the cropGuideView
}

@end

