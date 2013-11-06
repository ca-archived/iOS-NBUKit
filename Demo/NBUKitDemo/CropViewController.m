//
//  CropViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/07/31.
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
    __weak CropViewController * weakSelf = self;
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

