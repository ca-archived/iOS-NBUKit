//
//  NBUAssetsGroupViewController.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/01.
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

#import "NBUAssetsGroupViewController.h"
#import "NBUKitPrivate.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

// Private category
@interface NBUAssetsGroupViewController (Private) <ObjectArrayViewDelegate>

@end


@implementation NBUAssetsGroupViewController
{
    NSMutableArray * _selectedAssets;
}

@dynamic assetsGroup;
@synthesize reverseOrder = _reverseOrder;
@synthesize loadSize = _loadSize;
@synthesize loading = _loading;
@synthesize selectionCountLimit = _selectionCountLimit;
@synthesize clearsSelectionOnViewWillAppear = _clearsSelectionOnViewWillAppear;
@synthesize selectionChangedBlock = _selectionChangedBlock;
@synthesize assets = _assets;
@synthesize selectedAssetsURLs = _selectedAssetsURLs;
@synthesize gridView = _gridView;
@synthesize continueButton = _continueButton;

// TODO: Remove
- (void)setScrollOffset
{
    // *** Do nothing, just to avoit ScrollViewController from resetting the contentOffset ***
}

- (void)commonInit
{
    [super commonInit];
    
    _loadSize = 100;
    _selectedAssets = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure grid view
    _gridView.margin = CGSizeMake(4.0, 4.0);
    _gridView.nibNameForViews = @"NBUAssetThumbnailView";
    _gridView.equallySizedViews = YES;
    _gridView.animated = NO;
    _gridView.delegate = self;
    [_gridView startObservingScrollViewDidScroll];
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Clean up before reuse
    NBUAssetsGroup * oldGroup = userInfo[NBUObjectUpdatedOldObjectKey];
    if (oldGroup)
    {
        [oldGroup stopLoadingAssets];
        [_gridView resetGridView];
        [self resetScrollViewOffset];
        _selectedAssets = [NSMutableArray array];
    }
    
    // Configure UI
    self.title = self.assetsGroup.name;
    self.selectedAssets = nil;
    
    // Reload assets
    [self.assetsGroup stopLoadingAssets];
    NBULogVerbose(@"Loading images for group %@...", self.assetsGroup.name);
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.loading = YES;
                   });
    NSUInteger totalCount = self.assetsGroup.imageAssetsCount;
    __unsafe_unretained NBUAssetsGroupViewController * weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [weakSelf.assetsGroup assetsWithTypes:NBUAssetTypeImage
                                    atIndexes:nil
                                 reverseOrder:_reverseOrder
                          incrementalLoadSize:_loadSize
                                  resultBlock:^(NSArray * assets,
                                                NSError * error)
         {
             if (!error)
             {
                 _assets = assets;
                 
                 // Update from time to time only...
                 if (assets.count == 100 ||
                     assets.count == 400 ||
                     assets.count == totalCount)
                 {
                     NBULogVerbose(@"...%d images loaded", assets.count);
                     
                     // Stop loading?
                     if (assets.count == totalCount)
                     {
                         weakSelf.loading = NO;
                     }
                     
                     // Check for selectedAssets
                     NSArray * selectedAssets = [self selectedAssetsFromAssets:assets
                                                            selectedAssetsURLs:_selectedAssetsURLs];
                     
                     // Update grid view and selected assets on main thread
                     dispatch_async(dispatch_get_main_queue(), ^
                                    {
                                        self.selectedAssets = selectedAssets;
                                        weakSelf.gridView.objectArray = assets;
                                    });
                 }
             }
         }];
    });
    
}

- (void)setContinueButton:(id<UIButton>)continueButton
{
    _continueButton = continueButton;
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading; // Enables KVO
	
    // Update label
	if (_loading)
	{
        [_gridView setNoContentsViewText:NSLocalizedStringWithDefaultValue(@"NBUAssetsGroupViewController LoadingLabel",
																		   nil, nil,
																		   @"Loading images...",
																		   @"NBUAssetsGroupViewController LoadingLabel")];
	}
	else
	{
		[_gridView setNoContentsViewText:NSLocalizedStringWithDefaultValue(@"NBUAssetsGroupViewController NoImagesLabel",
																		   nil, nil,
																		   @"No images",
																		   @"NBUAssetsGroupViewController NoImagesLabel")];
	}
}

#pragma mark - Grid view delegate

- (void)objectArrayView:(ObjectArrayView *)arrayView
          configureView:(NBUAssetThumbnailView *)recycledView
             withObject:(NBUAsset *)asset
{
    recycledView.object = asset;
    recycledView.selected = [_selectedAssets containsObject:asset];
}

#pragma mark - Programatically managing selection

- (NSArray *)selectedAssets
{
    return [NSArray arrayWithArray:_selectedAssets];
}

- (void)setSelectedAssets:(NSArray *)selectedAssets
{
    _selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
    
    // Discard assets beyond the selection count limit
    if ((_selectionCountLimit > 0) &&
        (_selectedAssets.count > _selectionCountLimit))
    {
        [_selectedAssets removeObjectsInRange:NSMakeRange(_selectionCountLimit,
                                                          _selectedAssets.count - _selectionCountLimit)];
    }
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
    
    // Update current visible views
    for (NBUAssetThumbnailView * view in _gridView.currentViews)
    {
        view.selected = [selectedAssets containsObject:view.asset];
    }
    
    // Call the selection changed block
    if (_selectionChangedBlock) _selectionChangedBlock();
}

- (NSArray *)selectedAssetsFromAssets:(NSArray *)assets
                   selectedAssetsURLs:(NSArray *)selectedAssetsURLs
{
    NSMutableArray * selectedAssets;
    if (selectedAssetsURLs.count > 0)
    {
        selectedAssets = [NSMutableArray array];
        for (NBUAsset * asset in assets)
        {
            for (NSURL * url in selectedAssetsURLs)
            {
                if ([asset.URL.absoluteString isEqualToString:url.absoluteString])
                {
                    [selectedAssets addObject:asset];
                    break;
                }
            }
            // Stop looking if we found all of them
            if (selectedAssets.count == selectedAssetsURLs.count)
                break;
        }
    }
    return selectedAssets;
}

- (void)setSelectedAssetsURLs:(NSArray *)selectedAssetsURLs
{
    _selectedAssetsURLs = selectedAssetsURLs;
    
    self.selectedAssets = [self selectedAssetsFromAssets:self.assets
                                      selectedAssetsURLs:selectedAssetsURLs];
}

- (NSArray *)selectedAssetsURLs
{
    if (!self.isViewLoaded)
        return _selectedAssetsURLs;
    
    // Make sure that we have the latest URLs by recreating them from the actual selectedAssets
    NSMutableArray * selectedAssetsURLs = [NSMutableArray array];
    for (NBUAsset * asset in _selectedAssets)
    {
        [selectedAssetsURLs addObject:asset.URL];
    }
    _selectedAssetsURLs = selectedAssetsURLs;
    return selectedAssetsURLs;
}

#pragma mark - Manage taps

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thumbnailViewSelectionStateChanged:)
                                                 name:NBUAssetThumbnailViewSelectionStateChangedNotification
                                               object:nil];
    
    // Clear selection if in single selection mode
    if (_clearsSelectionOnViewWillAppear)
    {
        self.selectedAssets = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NBUAssetThumbnailViewSelectionStateChangedNotification
                                                  object:nil];
}

- (void)thumbnailViewSelectionStateChanged:(NSNotification *)notification
{
    // Refresh selected assets
    NBUAssetThumbnailView * assetView = (NBUAssetThumbnailView *)notification.object;
    
    // Selected
    if (assetView.selected)
    {
        // Prevent further selections?
        if ((_selectionCountLimit > 0) &&
            (_selectedAssets.count >= _selectionCountLimit))
        {
            assetView.selected = NO;
            return;
        }
        
        NBULogVerbose(@"Asset %p selected", assetView.asset);
        [_selectedAssets addObject:assetView.asset];
    }
    
    // Deselected
    else
    {
        NBULogVerbose(@"Asset %p deselected", assetView.asset);
        [_selectedAssets removeObject:assetView.asset];
    }
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
    
    // Call the selection changed block
    if (_selectionChangedBlock) _selectionChangedBlock();
}

@end

