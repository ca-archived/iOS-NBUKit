//
//  NBUAssetsLibraryViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/17.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetsLibraryViewController.h"
#import "ObjectTableView.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUAssetsLibraryViewController

@synthesize loading = _loading;
@synthesize assetsGroups = _assetsGroups;
@synthesize objectTableView = _objectTableView;
@synthesize groupControllerBlock = _groupControllerBlock;

// TODO: Remove
- (void)setScrollOffset
{
    // *** Do nothing, just to avoit ScrollViewController from resetting the contentOffset ***
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure object table view
    _objectTableView.nibNameForViews = @"NBUAssetsGroupView";
    
    // Try to load groups asynchronously
    [self loadGroups];
}

- (void)loadGroups
{
    self.loading = YES;
    
    [[NBUAssetsLibrary sharedLibrary] allGroupsWithResultBlock:^(NSArray * groups,
                                                                 NSError * error)
     {
         if (!error)
         {
             _assetsGroups = groups;

             NBULogInfo(@"%d available asset groups", groups.count);
             
             // Update UI
             self.navigationItem.title = (groups.count == 1 ?
                                          NSLocalizedString(@"1 album", @"Only one album") :
                                          [NSString stringWithFormat:
                                           NSLocalizedString(@"%d albums", @"Zero or more albums"), groups.count]);
             _objectTableView.objectArray = groups;
             
             // Force ScrollView's sizeToFitContentView
             [self sizeToFitContentView:self];
         }
         else
         {
             NBULogWarn(@"The user has denied access!");
             
             // Update UI
             self.navigationItem.title = error.localizedDescription;
         }
         
         self.loading = NO;
     }];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading; // Enables KVO
}

#pragma mark - Show assets group

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assetsGroupViewTapped:)
                                                 name:ActiveViewTappedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ActiveViewTappedNotification
                                                  object:nil];
}

- (void)assetsGroupViewTapped:(NSNotification *)notification
{
    NBUAssetsGroup * group = ((NBUAssetsGroupView *)notification.object).assetsGroup;
    
    if (![group isKindOfClass:[NBUAssetsGroup class]])
        return;
    
    UIViewController * controller;
    if (_groupControllerBlock)
    {
        controller = _groupControllerBlock(group);
    }
    else
    {
        controller = [[NBUAssetsGroupViewController alloc] initWithNibName:@"NBUAssetsGroupViewController"
                                                                    bundle:nil];
        ((NBUAssetsGroupViewController *)controller).assetsGroup = group;
    }
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

@end

