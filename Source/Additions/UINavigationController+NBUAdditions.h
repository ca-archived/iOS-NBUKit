//
//  UINavigationController+NBUAdditions.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/04.
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
 Convenience UINavigationController methods.

 - Additional properties to manage the viewControllers array.
 - Make methods available as IBActions.
 */
@interface UINavigationController (NBUAdditions)

/// @name Extended Properties

/// Shortcut to get/set the first view controller.
/// @note When set all other controllers will be removed.
@property(nonatomic, strong) UIViewController * rootViewController;

/// Convenience method to change the top view controller.
/// @param controller The new top view controller.
- (void)setTopViewController:(UIViewController *)controller;

/// @name Actions

/// Pop the top view controller.
/// @param sender The sender object.
- (IBAction)popViewController:(id)sender;

/// Pop to the root view controller.
/// @param sender The sender object.
- (IBAction)popToRootViewController:(id)sender;

@end

