//
//  NBUView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/15.
//  Copyright (c) 2012-2014 CyberAgent Inc.
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

