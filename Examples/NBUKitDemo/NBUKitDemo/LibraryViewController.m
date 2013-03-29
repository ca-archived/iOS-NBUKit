//
//  LibraryViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/11/09.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "LibraryViewController.h"
#import "AssetsGroupViewController.h"

@implementation LibraryViewController

+(void)initialize
{
    // Register our custom directory albums
//    [[NBUAssetsLibrary sharedLibrary] registerDirectoryGroupforURL:[NBUKit resourcesBundle].bundleURL
//                                                              name:nil];
//    [[NBUAssetsLibrary sharedLibrary] registerDirectoryGroupforURL:[NSBundle mainBundle].bundleURL
//                                                              name:nil];
    [[NBUAssetsLibrary sharedLibrary] registerDirectoryGroupforURL:[UIApplication sharedApplication].documentsDirectory
                                                              name:@"NBUKitDemo"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure grid view
    self.objectTableView.nibNameForViews = @"CustomAssetsGroupView";
    
    // Customization
    [self setCustomBackButtonTitle:@"Albums"];
    self.groupControllerBlock = ^UIViewController *(NBUAssetsGroup * group)
    {
        // *** The controller to be pushed when tapping on an assets group ***
        AssetsGroupViewController * controller = [[AssetsGroupViewController alloc] initWithNibName:@"NBUAssetsGroupViewController"
                                                                                             bundle:nil];
        controller.assetsGroup = group;
        
        return controller;
    };
}

#pragma mark - Handling access authorization

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Authorized?
    if (![NBUAssetsLibrary sharedLibrary].userDeniedAccess)
    {
        // No need for info button
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)accessInfo:(id)sender
{
    // User denied access?
    if ([NBUAssetsLibrary sharedLibrary].userDeniedAccess)
    {
        [[[UIAlertView alloc] initWithTitle:@"Access denied"
                                    message:@"Please go to Settings:Privacy:Photos to enable library access" delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    // Parental controls
    if ([NBUAssetsLibrary sharedLibrary].restrictedAccess)
    {
        [[[UIAlertView alloc] initWithTitle:@"Parental restrictions"
                                    message:@"Please go to Settings:General:Restrictions to enable library access" delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end

