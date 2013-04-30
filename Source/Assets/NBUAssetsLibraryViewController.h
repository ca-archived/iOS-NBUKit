//
//  NBUAssetsLibraryViewController.h
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

#import "ScrollViewController.h"

@class ObjectTableView, NBUAssetsGroup, NBUAssetsGroupViewController;

/**
 A simple controller to display a NBUAssetsGroup from the device library.
 
 - Pushes a NBUAssetsLibraryViewController on tap.
 */
@interface NBUAssetsLibraryViewController : ScrollViewController

/// @name Configurable Properties

/// An optional block to handle NBUAssetsGroup selection.
/// @discussion If set, the assetsGroupController won't be pushed automatically.
@property (nonatomic, copy)                         void (^groupSelectedBlock)(NBUAssetsGroup * group);

/// @name Read-only Properties

/// Whether or not the controller is loading assets groups (KVO compliant).
@property (nonatomic, readonly, getter=isLoading)   BOOL loading;

/// The currently retrieved NBUAssetsGroup objects.
@property (strong, nonatomic, readonly)             NSArray * assetsGroups;

/// @name Outlets

/// An ObjectTableView used to display library's NBUAssetsGroup objects.
@property (assign, nonatomic) IBOutlet              ObjectTableView * objectTableView;

/// The assets group controller to be pushed by default.
@property (strong, nonatomic) IBOutlet              NBUAssetsGroupViewController * assetsGroupController;

@end

