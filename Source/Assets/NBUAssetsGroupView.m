//
//  NBUAssetsGroupView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/17.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetsGroupView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

static UIImage * _noContentsImage;

@implementation NBUAssetsGroupView

@dynamic assetsGroup;
@synthesize nameLabel = _nameLabel;
@synthesize countLabel = _countLabel;
@synthesize posterImageView = _posterImageView;
@synthesize editableView = _editableView;

- (void)commonInit
{
    [super commonInit];
    
    self.recognizeTap = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Localization
    if ([_editableView isKindOfClass:[UILabel class]])
    {
        ((UILabel *)_editableView).text  = NSLocalizedString(@"editable",
                                                             @"NBUAssetsGroupView EditableLabel");
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _noContentsImage = _posterImageView.image;
    });
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Update UI
    _nameLabel.text = self.object.name;
    _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d images",
                                                                    @"AssetsGroupView NumberOfImages"),
                        self.assetsGroup.imageAssetsCount];
    _posterImageView.image = self.object.posterImage ? self.object.posterImage : _noContentsImage;
    _editableView.hidden = !self.object.editable;
}

@end

