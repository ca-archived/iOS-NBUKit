//
//  NBUAssetsGroupView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/17.
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

#import "NBUAssetsGroupView.h"
#import "NBUKitPrivate.h"

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
        ((UILabel *)_editableView).text  = NSLocalizedStringWithDefaultValue(@"NBUAssetsGroupView Editable label",
                                                                             nil, nil,
                                                                             @"editable",
                                                                             @"NBUAssetsGroupView Editable label");
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
    _countLabel.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"NBUAssetsGroupView Number of images",
                                                                                    nil, nil,
                                                                                    @"%d images",
                                                                                    @"NBUAssetsGroupView Number of images"),
                        self.assetsGroup.imageAssetsCount];
    _posterImageView.image = self.object.posterImage ? self.object.posterImage : _noContentsImage;
    _editableView.hidden = !self.object.editable;
}

@end

