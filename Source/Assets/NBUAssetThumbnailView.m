//
//  NBUAssetThumbnailView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/08.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetThumbnailView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUAssetThumbnailView

@synthesize selected = _selected;
@synthesize checkmark = _checkmark;

- (void)commonInit
{
    [super commonInit];
    
    // Configure view
    self.targetImageSize = NBUAssetImageSizeThumbnail;
    self.recognizeTap = YES;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    // Update UI
    _checkmark.hidden = selected ? NO : YES;
    self.imageView.alpha = selected ? 0.7 : 1.0;
}

- (void)tapped:(id)sender
{
    self.selected = !_selected;
    
    [super tapped:sender];
}

@end

