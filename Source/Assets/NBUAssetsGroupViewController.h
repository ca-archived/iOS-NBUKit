//
//  NBUAssetsGroupViewController.h
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

#import "NBUObjectViewController.h"

@class ObjectGridView, NBUAssetsGroup;
@protocol UIButton;

/**
 An extensible controller to display a NBUAssetsGroup's assets as thumbnails.
 
 - Keeps track of selected NBUAssets.
 - Seletected assets can be set programatically.
 - Can be reused with different assets groups.
 */
@interface NBUAssetsGroupViewController : NBUObjectViewController

/// @name Configurable Properties

/// The associated NBUAssetsGroup.
@property (strong, nonatomic, setter=setObject:,
                              getter=object)        NBUAssetsGroup * assetsGroup;

/// Whether to present reverse the assets' order (newest assets on top). Default `NO`.
@property (nonatomic)                               BOOL reverseOrder;

/// The number of assets to be incrementally loaded. Default `100`, set to `0` to load all at once;
@property (nonatomic)                               NSUInteger loadSize;

/// @name Managing Selection

/// The currently selected NBUAsset objects.
@property (strong, nonatomic)                       NSArray * selectedAssets;

/// An optional block to be called when the selection changes.
@property (nonatomic, copy)                         void (^selectionChangedBlock)();

/// The maximum number of assets that can be selected. Default `0` which means no limit.
@property (nonatomic)                               NSUInteger selectionCountLimit;

/// Whether the controller should clear selection automatically when being presented.
@property (nonatomic)                               BOOL clearsSelectionOnViewWillAppear;

/// @name Read-only Properties

/// Whether or not the controller is loading assets (KVO compliant).
@property (nonatomic, readonly, getter=isLoading)   BOOL loading;

/// The currently retrieved NBUAsset objects.
@property (strong, nonatomic, readonly)             NSArray * assets;

/// @name Outlets

/// An ObjectGridView used to display group's NBUAsset objects.
@property (assign, nonatomic) IBOutlet              ObjectGridView * gridView;

/// An optional UIButton or UIBarButtonItem that will be automatically disabled/enabled as selection changes.
/// @discussion You should configure the button's target actions separatly.
@property (assign, nonatomic) IBOutlet              id<UIButton> continueButton;

@end

