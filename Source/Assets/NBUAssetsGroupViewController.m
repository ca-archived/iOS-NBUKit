//
//  NBUAssetsGroupViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetsGroupViewController.h"
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
@synthesize singleImageMode = _singleImageMode;
@synthesize selectionChangedBlock = _selectionChangedBlock;
@synthesize assets = _assets;
@synthesize gridView = _gridView;

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
    
    // Localization
    [_gridView setNoContentsViewText:NSLocalizedString(@"No images",
                                                       @"NBUAssetsGroupViewController NoImagesLabel")];
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
    
    // Reload assets
    [self.assetsGroup stopLoadingAssets];
    NBULogVerbose(@"Loading images for group %@...", self.assetsGroup.name);
    self.loading = YES;
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
                 
                 // Update grid view from time to time
                 if (assets.count == 100 ||
                     assets.count == 400 ||
                     assets.count == totalCount)
                 {
                     NBULogVerbose(@"...%d images loaded", assets.count);
                     if (assets.count == totalCount)
                     {
                         weakSelf.loading = NO;
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         weakSelf.gridView.objectArray = assets;
                     });
                 }
             }
         }];
    });
    
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading; // Enables KVO
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
    
    // Update current visible views
    for (NBUAssetThumbnailView * view in _gridView.currentViews)
    {
        view.selected = [selectedAssets containsObject:view.asset];
    }
}

#pragma mark - Manage taps

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageAssetViewTapped:)
                                                 name:ActiveViewTappedNotification
                                               object:nil];
    
    // Clear selection if in single selection mode
    if (_singleImageMode)
    {
        self.selectedAssets = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ActiveViewTappedNotification
                                                  object:nil];
}

- (void)imageAssetViewTapped:(NSNotification *)notification
{
    // Refresh selected assets
    NBUAssetThumbnailView * assetView = (NBUAssetThumbnailView *)notification.object;
    
    if (![assetView isKindOfClass:[NBUAssetThumbnailView class]])
        return;
    
    if (assetView.selected)
    {
        NBULogVerbose(@"Asset %p selected", assetView.asset);
        [_selectedAssets addObject:assetView.asset];
    }
    else
    {
        NBULogVerbose(@"Asset %p deselected", assetView.asset);
        [_selectedAssets removeObject:assetView.asset];
    }
    
    // Call the selection changed block
    if (_selectionChangedBlock) _selectionChangedBlock();
}

@end

