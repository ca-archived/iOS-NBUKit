//
//  NBUAssetsLibraryViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/17.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "ScrollViewController.h"

@class ObjectTableView, NBUAssetsGroup;

/**
 A simple controller to display a NBUAssetsGroup from the device library.
 
 - Pushes a NBUAssetsLibraryViewController on tap.
 */
@interface NBUAssetsLibraryViewController : ScrollViewController

/// @name Configurable Properties

/// An optional block to get a ready to use UIViewController configured with a NBUAssetsGroup object.
@property (strong, nonatomic) UIViewController *(^groupControllerBlock)(NBUAssetsGroup * group);

/// @name Read-only Properties

/// Whether or not the controller is loading assets groups (KVO compliant).
@property (nonatomic, readonly, getter=isLoading)   BOOL loading;

/// The currently retrieved NBUAssetsGroup objects.
@property (strong, nonatomic, readonly)             NSArray * assetsGroups;

/// @name Outlets

/// An ObjectTableView used to display library's NBUAssetsGroup objects.
@property (assign, nonatomic) IBOutlet ObjectTableView * objectTableView;

@end

