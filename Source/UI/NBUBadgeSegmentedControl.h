//
//  NBUBadgeSegmentedControl.h
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/04/20.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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

