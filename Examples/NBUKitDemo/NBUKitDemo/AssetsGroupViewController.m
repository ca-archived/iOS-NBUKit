//
//  AssetsGroupViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/11/09.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
    
    // Add next button
    _nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"AssetsGroupViewController Next button")
                                                   style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(pushSlideView:)];
    _nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _nextButton;
    
    // Set the selection changed block
    __unsafe_unretained AssetsGroupViewController * weakSelf = self;
    self.selectionChangedBlock = ^()
    {
        weakSelf.nextButton.enabled = weakSelf.selectedAssets.count > 0;
    };
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
    NSMutableArray * fullScreenImages = [NSMutableArray array];
    for (NBUAsset * asset in selectedAssets)
    {
        [fullScreenImages addObject:asset.fullScreenImage];
    }
    
    // Push the slide view controller
    UIViewController * controller = [[NSBundle loadNibNamed:@"SlideViewController"
                                                      owner:nil
                                                    options:nil] objectAtIndex:0];
    controller.title = [NSString stringWithFormat:@"%d images", selectedAssets.count];
    ((ObjectSlideView *)controller.view).objectArray = fullScreenImages;
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

@end

