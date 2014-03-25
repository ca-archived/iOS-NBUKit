//
//  UITabBarController+NBUAdditions.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/18.
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
 UITabBarController category to provide tabBar show/hide functionality.
 
 @discussion The tabBar is hidden by stretching the controller's view enough to bring
 the bar outside the screen (or more precisely outside the originalViewFrame).
 */
@interface UITabBarController (NBUAdditions)

/// @name Showing/Hiding the Tab Bar

/// The original controller's view frame, that will used for the non-hidden state.
@property (nonatomic)                       CGRect originalViewFrame;

/// Wheter the UITabBar is hidden. Modifying this value shows/hides the tabBar.
@property(nonatomic,getter=isTabBarHidden) BOOL tabBarHidden;

/// Show/hide the UITabBar with animation.
/// @param hidden Whether the tabBar should be hidden.
/// @param animated Whether the change should be animated.
- (void)setTabBarHidden:(BOOL)hidden
               animated:(BOOL)animated;

@end
