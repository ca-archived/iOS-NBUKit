//
//  NBUAssetsGroupViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUObjectViewController.h"

@class ObjectGridView, NBUAssetsGroup;

/**
 An extensible controller to display a NBUAssetsGroup's assets as thumbnails.
 
 - Keeps track of selected NBUAssets.
 - Seletected assets can be set programatically.
 - Can be reused with different assets groups.
 */
@interface NBUAssetsGroupViewController : NBUObjectViewController

/// @name Configurable Properties

/// The associated NBUAssetsGroup.
@property (strong, nonatomic, setter = setObject:, getter = object) NBUAssetsGroup * assetsGroup;

/// Whether to present reverse the assets' order (newest assets on top). Default `NO`.
@property (nonatomic)                               BOOL reverseOrder;

/// The number of assets to be incrementally loaded. Default `100`, set to `0` to load all at once;
@property (nonatomic)                               NSUInteger loadSize;

/// Whether to use single selection mode. Default `NO`.
///
/// In this mode selection will always be cleared before the view reappears.
@property (nonatomic)                               BOOL singleImageMode;

/// The currently selected NBUAsset objects.
@property (strong, nonatomic)                       NSArray * selectedAssets;

/// An optional block to be called when the selection changes.
@property (strong, nonatomic)                       void(^selectionChangedBlock)();

/// @name Read-only Properties

/// Whether or not the controller is loading assets (KVO compliant).
@property (nonatomic, readonly, getter=isLoading)   BOOL loading;

/// The currently retrieved NBUAsset objects.
@property (strong, nonatomic, readonly)             NSArray * assets;

/// @name Outlets

/// An ObjectGridView used to display group's NBUAsset objects.
@property (assign, nonatomic) IBOutlet              ObjectGridView * gridView;

@end

