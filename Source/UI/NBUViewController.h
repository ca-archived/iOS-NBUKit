//
//  NBUViewController.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/09.
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
 Main UIViewController superclass to ease common tasks.
 
 - Call commonInit for init:, initWithNibName:bundle: and initWithCoder: methods to ease subclasses implementation.
 - Allow to set the supportedInterfaceOrientations even on iOS4.
 - Read the default supportedInterfaceOrientations from Info.plist from iOS4+.
 */
@interface NBUViewController : UIViewController

/// @name Initialization

/// A method called by both initWithFrame: and initWithCoder: methods.
/// @note Subclasses should call super's commonInit.
- (void)commonInit;

/// Set the controller's supported orientations directly.
@property (nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;

@end

