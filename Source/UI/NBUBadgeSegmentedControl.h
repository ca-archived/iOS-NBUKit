//
//  NBUBadgeSegmentedControl.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/04/20.
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
 A UISegmentedControl that supports badges using NBUBadgeView instances.
 
 @note Can be initialized from a Nib or programatically.
 */
@interface NBUBadgeSegmentedControl : UISegmentedControl

/// Set/clear a segment badge.
/// @param badge Set to `nil` or `@""` to hide.
/// @param index A UISegmentedControl index.
- (void)setBadge:(NSString *)badge
forSegmentAtIndex:(NSUInteger)index;

/// Get a segment badge value.
/// @param index A UISegmentedControl index.
- (NSString *)getBadgeForIndex:(NSUInteger)index;

@end

