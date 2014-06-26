//
//  UIScrollView+NBUAdditions.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/17.
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
 Methods to easily scroll a UIScrollView to any edge.
 */
@interface UIScrollView (NBUAdditions)

/// @name Scrolling to Edges

/// Scroll to the top.
/// @param animated Whether to animate scrolling or not.
- (void)scrollToTopAnimated:(BOOL)animated;

/// Scroll to the top.
/// @param sender The sender object.
- (IBAction)scrollToTop:(id)sender;

/// Scroll to the bottom.
/// @param animated Whether to animate scrolling or not.
- (void)scrollToBottomAnimated:(BOOL)animated;

/// Scroll to the left.
/// @param animated Whether to animate scrolling or not.
- (void)scrollToLeftAnimated:(BOOL)animated;

/// Scroll to the right.
/// @param animated Whether to animate scrolling or not.
- (void)scrollToRightAnimated:(BOOL)animated;

/// @name Auto-Adjusting

/// Try to adjust the content size with the first subview as reference.
- (void)autoAdjustContentSize;

/// Adjust insets iOS 7-style and make sure to update the contentOffest if needed.
/// @note You may have to call this method as late as `viewDidAppear:`.
- (void)autoAdjustInsets;

@end

