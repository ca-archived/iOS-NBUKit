//
//  AssetsGroupViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/11/09.
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

#import "AssetsGroupViewController.h"

@implementation AssetsGroupViewController

@synthesize nextButton = _nextButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the grid view
    self.gridView.margin = CGSizeMake(5.0, 5.0);
    self.gridView.nibNameForViews = @"CustomAssetThumbnailView";
    
    // Add a next (continue) button
    _nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                   style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(pushSlideView:)];
    self.navigationItem.rightBarButtonItem = _nextButton;
    self.continueButton = _nextButton;
    
    // Configure the selection behaviour
    self.selectionCountLimit = 4;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop loading assets?
    if (!self.navigationController)
    {
        [self.assetsGroup stopLoadingAssets];
    }
}

- (IBAction)pushSlideView:(id)sender
{
    // Get selected asstes' fullscreen images
    NSArray * selectedAssets = self.selectedAssets;
    
    // Push the gallery view controller
    NBUGalleryViewController * controller = [NBUGalleryViewController new];
    controller.objectArray = selectedAssets;
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

@end

