//
//  NBUViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/09.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 Main UIViewController superclass to ease common tasks.
 
 - Call commonInit for init:, initWithNibName:bundle: and initWithCoder: methods to ease subclasses implementation.
 - Allow to set the supportedInterfaceOrientations even on iOS4.
 - Read the default supportedInterfaceOrientations from Info.plist from iOS4+.
 - Make navigationItem an IBOutlet.
 */
@interface NBUViewController : UIViewController

/// @name Initialization

/// A method called by both initWithFrame: and initWithCoder: methods.
/// @note Subclasses should call super's commonInit.
- (void)commonInit;

/// Set the controller's supported orientations directly.
@property (nonatomic) NSUInteger supportedInterfaceOrientations;

/// @name Outlets

/// Navigation item as an IB outlet.
@property(nonatomic, readonly, retain) IBOutlet UINavigationItem * navigationItem;

@end

