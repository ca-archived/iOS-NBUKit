//
//  NBUAssetsLibraryViewController.m
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

#import "NBUAssetsLibraryViewController.h"
#import "NBUKitPrivate.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUAssetsLibraryViewController

@synthesize loading = _loading;
@synthesize assetsGroups = _assetsGroups;
@synthesize objectTableView = _objectTableView;
@synthesize groupSelectedBlock = _groupSelectedBlock;
@synthesize assetsGroupController = _assetsGroupController;

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
                                          NSLocalizedStringWithDefaultValue(@"NBUAssetsLibraryViewController Only one album",
                                                                            nil, nil,
                                                                            @"1 album",
                                                                            @"NBUAssetsLibraryViewController Only one album") :
                                          [NSString stringWithFormat:
                                           NSLocalizedStringWithDefaultValue(@"NBUAssetsLibraryViewController Zero or more albums",
                                                                             nil, nil,
                                                                             @"%d albums", @"NBUAssetsLibraryViewController Zero or more albums"),
                                           groups.count]);
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
    
    // Custom block?
    if (_groupSelectedBlock)
    {
        _groupSelectedBlock(group);
        return;
    }
    
    // Else just push a our assets controller
    if (!_assetsGroupController)
    {
        _assetsGroupController = [[NBUAssetsGroupViewController alloc] initWithNibName:@"NBUAssetsGroupViewController"
                                                                                bundle:nil];
    }
    _assetsGroupController.assetsGroup = group;
    [self.navigationController pushViewController:_assetsGroupController
                                         animated:YES];
}

@end

