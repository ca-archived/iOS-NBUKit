//
//  NBUView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/10/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 Enriched UIView to ease common tasks.

 - Call commonInit for initWithFrame: and initWithCoder: methods to ease subclasses implementation.
 - Provide UIViewController-like viewWill/DidAppear/Disappear.
 */
@interface NBUView : UIView

/// @name Initialization

/// A method called by both initWithFrame: and initWithCoder: methods.
/// @note Subclasses should call super's commonInit.
- (void)commonInit;

/// @name View Moving in/out of a Window

/// Called when the view will be added to a UIWindow.
- (void)viewWillAppear;

/// Called after the view was added to a UIWindow.
- (void)viewDidAppear;

/// Called when the view will be removed from a UIWindow.
- (void)viewWillDisappear;

/// Called after the view was removed from a UIWindow.
- (void)viewDidDisappear;

@end

